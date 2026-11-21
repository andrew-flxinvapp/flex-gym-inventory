import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../service/revenuecat_service.dart';
import '../utilities/logging_handler.dart' as app_log;

enum SubscriptionStatus { loading, signedOut, free, pro, unavailable }

/// Subscription information for the current authenticated session only.
class SubscriptionState {
  const SubscriptionState({
    required this.status,
    this.isRefreshing = false,
    this.lastKnownStatus,
    this.customerInfoRequestedAt,
    this.errorMessage,
  });

  final SubscriptionStatus status;
  final bool isRefreshing;

  /// The last successful status for this session, retained on refresh failure.
  /// It is not a current entitlement confirmation.
  final SubscriptionStatus? lastKnownStatus;

  /// RevenueCat's request date; cached information may be older than this app session.
  final DateTime? customerInfoRequestedAt;
  final String? errorMessage;
}

final revenueCatServiceProvider = Provider<RevenueCatService>(
  (ref) => RevenueCatService.instance,
);

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      return SubscriptionNotifier(ref.watch(revenueCatServiceProvider));
    });

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this._service)
    : super(const SubscriptionState(status: SubscriptionStatus.loading)) {
    _service.initializationState.addListener(_reconcile);
    _service.identityState.addListener(_reconcile);
    _reconcile();
  }

  final RevenueCatService _service;
  late final CustomerInfoUpdateListener _customerInfoListener = _onCustomerInfo;
  bool _disposed = false;
  bool _listenerRegistered = false;
  bool _registeringListener = false;
  bool _identityObserved = false;
  bool _ready = false;
  String? _userId;
  int _identityRevision = -1;
  int _generation = 0;
  Future<void>? _activeRefresh;
  CustomerInfo? _lastListenerInfo;
  CustomerInfo? _pendingListenerInfo;

  void _reconcile() {
    if (_disposed) return;
    String? userId;
    try {
      userId = _service.currentSupabaseUserId;
    } catch (_) {
      _invalidate();
      state = const SubscriptionState(
        status: SubscriptionStatus.unavailable,
        errorMessage: 'Supabase authentication state is unavailable.',
      );
      return;
    }

    final revision = _service.identityRevision;
    if (!_identityObserved ||
        _userId != userId ||
        _identityRevision != revision) {
      _invalidate();
      _identityObserved = true;
      _userId = userId;
      _identityRevision = revision;
      _lastListenerInfo = null;
    }

    if (userId == null) {
      _ready = false;
      state = const SubscriptionState(status: SubscriptionStatus.signedOut);
      return;
    }

    final initialization = _service.initializationState.value.status;
    final identity = _service.identityState.value.status;
    if (initialization == RevenueCatInitializationStatus.failed ||
        initialization == RevenueCatInitializationStatus.unavailable ||
        identity == RevenueCatIdentityStatus.failed ||
        identity == RevenueCatIdentityStatus.unavailable ||
        identity == RevenueCatIdentityStatus.stopped) {
      _invalidate();
      state = const SubscriptionState(
        status: SubscriptionStatus.unavailable,
        errorMessage: 'RevenueCat subscription identity is unavailable.',
      );
      return;
    }
    if (initialization != RevenueCatInitializationStatus.configured ||
        !_service.isCurrentSupabaseUserSynchronized) {
      _invalidate();
      state = const SubscriptionState(status: SubscriptionStatus.loading);
      return;
    }

    if (!_listenerRegistered) {
      try {
        _registeringListener = true;
        _service.addCustomerInfoUpdateListener(_customerInfoListener);
        _listenerRegistered = true;
      } catch (_) {
        _invalidate();
        app_log.LogHandler.warning(
          'Subscription',
          'Could not register the RevenueCat customer information listener.',
        );
        state = const SubscriptionState(
          status: SubscriptionStatus.unavailable,
          errorMessage: 'Subscription updates are unavailable.',
        );
        return;
      } finally {
        _registeringListener = false;
      }
    }
    if (!_ready) {
      _ready = true;
      unawaited(refresh());
    }
  }

  void _invalidate() {
    _generation++;
    _ready = false;
    _activeRefresh = null;
    _pendingListenerInfo = null;
  }

  void _onCustomerInfo(CustomerInfo info) {
    if (_disposed ||
        _registeringListener ||
        !_ready ||
        !_service.isCurrentSupabaseUserSynchronized ||
        _service.identityRevision != _identityRevision) {
      return;
    }
    if (info == _lastListenerInfo) return;
    _lastListenerInfo = info;
    if (_activeRefresh != null) {
      _pendingListenerInfo = info;
    } else {
      unawaited(refresh());
    }
  }

  /// Refreshes using the SDK's normal cache policy; it does not force a network fetch.
  Future<void> refresh() {
    if (_disposed) return Future<void>.value();
    if (!_isCurrent(_generation, _identityRevision)) {
      _reconcile();
      if (!_ready) return Future<void>.value();
    }
    final active = _activeRefresh;
    if (active != null) return active;

    final generation = _generation;
    final revision = _identityRevision;
    final previous = state;
    final task = Future<void>.microtask(() => _fetch(generation, revision));
    _activeRefresh = task;
    state = SubscriptionState(
      status: previous.status,
      isRefreshing: true,
      lastKnownStatus: previous.lastKnownStatus,
      customerInfoRequestedAt: previous.customerInfoRequestedAt,
      errorMessage: previous.errorMessage,
    );
    return task;
  }

  bool _isCurrent(int generation, int revision) {
    if (_disposed ||
        !_ready ||
        generation != _generation ||
        revision != _service.identityRevision ||
        !_service.isCurrentSupabaseUserSynchronized) {
      return false;
    }
    try {
      return _service.currentSupabaseUserId == _userId;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetch(int generation, int revision) async {
    try {
      while (true) {
        if (!_isCurrent(generation, revision)) {
          _reconcileIfCurrentGeneration(generation);
          return;
        }
        final info = await _service.getCustomerInfo();
        if (!_isCurrent(generation, revision)) {
          _reconcileIfCurrentGeneration(generation);
          return;
        }
        if (info == null) {
          throw StateError('RevenueCat returned no customer information.');
        }

        final pending = _pendingListenerInfo;
        _pendingListenerInfo = null;
        if (pending != null && pending != info) continue;

        final status =
            RevenueCatService.hasActiveProEntitlement(info)
                ? SubscriptionStatus.pro
                : SubscriptionStatus.free;
        _lastListenerInfo = info;
        state = SubscriptionState(
          status: status,
          lastKnownStatus: status,
          customerInfoRequestedAt: DateTime.tryParse(info.requestDate),
        );
        return;
      }
    } catch (_) {
      if (!_isCurrent(generation, revision)) {
        _reconcileIfCurrentGeneration(generation);
        return;
      }
      _lastListenerInfo = null;
      app_log.LogHandler.warning(
        'Subscription',
        'Customer information refresh failed.',
      );
      state = SubscriptionState(
        status: SubscriptionStatus.unavailable,
        lastKnownStatus: state.lastKnownStatus,
        customerInfoRequestedAt: state.customerInfoRequestedAt,
        errorMessage: 'RevenueCat customer information is unavailable.',
      );
    } finally {
      if (!_disposed && generation == _generation) {
        _activeRefresh = null;
        _pendingListenerInfo = null;
      }
    }
  }

  void _reconcileIfCurrentGeneration(int generation) {
    if (!_disposed && generation == _generation) _reconcile();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _service.initializationState.removeListener(_reconcile);
    _service.identityState.removeListener(_reconcile);
    if (_listenerRegistered) {
      _service.removeCustomerInfoUpdateListener(_customerInfoListener);
    }
    super.dispose();
  }
}
