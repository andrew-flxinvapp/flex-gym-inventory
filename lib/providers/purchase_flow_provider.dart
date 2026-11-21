import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../service/revenuecat_service.dart';
import '../utilities/logging_handler.dart' as app_log;
import 'subscription_provider.dart';

enum OfferingStatus { loading, ready, unavailable }

enum SubscriptionPlan { monthly, annual }

enum TransactionOutcome {
  confirmed,
  cancelled,
  pending,
  noEntitlement,
  failed,
  identityChanged,
}

class PurchaseFlowState {
  const PurchaseFlowState({
    this.status = OfferingStatus.loading,
    this.monthly,
    this.annual,
    this.isBusy = false,
    this.message,
  });

  final OfferingStatus status;
  final Package? monthly;
  final Package? annual;
  final bool isBusy;
  final String? message;

  Package? packageFor(SubscriptionPlan plan) =>
      plan == SubscriptionPlan.monthly ? monthly : annual;
}

final purchaseFlowProvider =
    StateNotifierProvider<PurchaseFlowNotifier, PurchaseFlowState>((ref) {
      return PurchaseFlowNotifier(ref, ref.watch(revenueCatServiceProvider));
    });

class PurchaseFlowNotifier extends StateNotifier<PurchaseFlowState> {
  PurchaseFlowNotifier(this._ref, this._service)
    : super(const PurchaseFlowState()) {
    _service.initializationState.addListener(_reconcile);
    _service.identityState.addListener(_reconcile);
    _reconcile();
  }

  static const offeringId = 'fgi_pro';
  static const monthlyPackageId = r'$rc_monthly';
  static const annualPackageId = r'$rc_annual';
  static const monthlyProductId = 'fgi.pro.monthly';
  static const annualProductId = 'fgi.pro.annual';

  final Ref _ref;
  final RevenueCatService _service;
  int _revision = -1;
  int _generation = 0;
  bool _requested = false;
  bool _busy = false;
  bool _disposed = false;

  void _reconcile() {
    if (_disposed) return;
    final revision = _service.identityRevision;
    if (_revision != revision) {
      _revision = revision;
      _generation++;
      _requested = false;
      state = PurchaseFlowState(isBusy: _busy);
    }

    if (!_service.isCurrentSupabaseUserSynchronized) {
      _generation++;
      _requested = false;
      final initialization = _service.initializationState.value.status;
      final identity = _service.identityState.value.status;
      final failed =
          initialization == RevenueCatInitializationStatus.failed ||
          initialization == RevenueCatInitializationStatus.unavailable ||
          identity == RevenueCatIdentityStatus.failed ||
          identity == RevenueCatIdentityStatus.unavailable ||
          identity == RevenueCatIdentityStatus.signedOut ||
          identity == RevenueCatIdentityStatus.stopped;
      state = PurchaseFlowState(
        status: failed ? OfferingStatus.unavailable : OfferingStatus.loading,
        isBusy: _busy,
        message:
            identity == RevenueCatIdentityStatus.signedOut
                ? 'Sign in to purchase or restore subscriptions.'
                : failed
                ? 'Subscriptions are currently unavailable.'
                : null,
      );
      return;
    }
    if (!_requested) unawaited(_load());
  }

  bool _current(int generation, int revision) =>
      !_disposed &&
      generation == _generation &&
      revision == _service.identityRevision &&
      _service.isCurrentSupabaseUserSynchronized;

  Future<void> retry() async {
    if (!_service.isCurrentSupabaseUserSynchronized || _busy) return;
    if (state.status == OfferingStatus.loading && _requested) return;
    await _load();
  }

  Future<void> _load() async {
    _requested = true;
    final generation = ++_generation;
    final revision = _service.identityRevision;
    state = PurchaseFlowState(isBusy: _busy);
    try {
      final offerings = await _service.getCurrentOffering();
      if (!_current(generation, revision)) return;
      final offering = offerings?.all[offeringId];
      final monthly = offering?.getPackage(monthlyPackageId);
      final annual = offering?.getPackage(annualPackageId);
      if (offering?.identifier != offeringId ||
          monthly?.storeProduct.identifier != monthlyProductId ||
          annual?.storeProduct.identifier != annualProductId ||
          monthly?.presentedOfferingContext.offeringIdentifier != offeringId ||
          annual?.presentedOfferingContext.offeringIdentifier != offeringId ||
          monthly?.packageType != PackageType.monthly ||
          annual?.packageType != PackageType.annual ||
          monthly!.storeProduct.priceString.isEmpty ||
          annual!.storeProduct.priceString.isEmpty) {
        throw StateError('Expected subscription packages are unavailable.');
      }
      state = PurchaseFlowState(
        status: OfferingStatus.ready,
        monthly: monthly,
        annual: annual,
        isBusy: _busy,
      );
    } catch (_) {
      if (!_current(generation, revision)) return;
      app_log.LogHandler.warning(
        'PurchaseFlow',
        'Subscription offerings are unavailable.',
      );
      state = PurchaseFlowState(
        status: OfferingStatus.unavailable,
        isBusy: _busy,
        message: 'Subscription plans are unavailable. Please try again.',
      );
    }
  }

  void _setBusy(bool busy) {
    _busy = busy;
    if (_disposed) return;
    state = PurchaseFlowState(
      status: state.status,
      monthly: state.monthly,
      annual: state.annual,
      isBusy: busy,
      message: state.message,
    );
  }

  Future<TransactionOutcome> purchase(SubscriptionPlan plan) async {
    final package = state.packageFor(plan);
    if (_busy ||
        state.status != OfferingStatus.ready ||
        package == null ||
        !_service.isCurrentSupabaseUserSynchronized) {
      return TransactionOutcome.failed;
    }
    final revision = _service.identityRevision;
    _setBusy(true);
    try {
      final result = await _service.purchasePackage(package);
      if (_disposed ||
          revision != _service.identityRevision ||
          !_service.isCurrentSupabaseUserSynchronized ||
          result.identityChanged) {
        return TransactionOutcome.identityChanged;
      }
      if (result.cancelled) return TransactionOutcome.cancelled;
      if (result.pending) return TransactionOutcome.pending;
      if (!result.success) return TransactionOutcome.failed;
      await _ref.read(subscriptionProvider.notifier).refresh();
      if (_disposed ||
          revision != _service.identityRevision ||
          !_service.isCurrentSupabaseUserSynchronized) {
        return TransactionOutcome.identityChanged;
      }
      return _ref.read(subscriptionProvider).status == SubscriptionStatus.pro
          ? TransactionOutcome.confirmed
          : TransactionOutcome.pending;
    } finally {
      _setBusy(false);
    }
  }

  Future<TransactionOutcome> restore() async {
    if (_busy || !_service.isCurrentSupabaseUserSynchronized) {
      return TransactionOutcome.failed;
    }
    final revision = _service.identityRevision;
    _setBusy(true);
    try {
      final info = await _service.restorePurchases();
      if (_disposed ||
          revision != _service.identityRevision ||
          !_service.isCurrentSupabaseUserSynchronized) {
        return TransactionOutcome.identityChanged;
      }
      if (info == null) return TransactionOutcome.pending;
      bool? hadPro;
      try {
        hadPro = RevenueCatService.hasActiveProEntitlement(info);
      } catch (_) {
        app_log.LogHandler.warning(
          'PurchaseFlow',
          'Restored subscription information could not be verified.',
        );
      }
      await _ref.read(subscriptionProvider.notifier).refresh();
      if (_disposed ||
          revision != _service.identityRevision ||
          !_service.isCurrentSupabaseUserSynchronized) {
        return TransactionOutcome.identityChanged;
      }
      final status = _ref.read(subscriptionProvider).status;
      if (status == SubscriptionStatus.pro) return TransactionOutcome.confirmed;
      if (status == SubscriptionStatus.free && hadPro == false) {
        return TransactionOutcome.noEntitlement;
      }
      return TransactionOutcome.pending;
    } catch (_) {
      if (_disposed ||
          revision != _service.identityRevision ||
          !_service.isCurrentSupabaseUserSynchronized) {
        return TransactionOutcome.identityChanged;
      }
      return TransactionOutcome.failed;
    } finally {
      _setBusy(false);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _service.initializationState.removeListener(_reconcile);
    _service.identityState.removeListener(_reconcile);
    super.dispose();
  }
}
