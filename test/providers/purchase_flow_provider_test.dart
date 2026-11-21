import 'dart:async';
import 'dart:collection';

import 'package:flex_gym_inventory/providers/purchase_flow_provider.dart';
import 'package:flex_gym_inventory/providers/subscription_provider.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/service/revenuecat_service.dart';
import 'package:flex_gym_inventory/src/providers/price_provider.dart';
import 'package:flex_gym_inventory/src/screens/ob_pro_purchase.dart';
import 'package:flex_gym_inventory/src/screens/pro_purchase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const userA = 'user-a';
const userB = 'user-b';
const anonymous = r'$RCAnonymousID:test';
const timestamp = '2026-11-21T00:00:00Z';

Package package({
  required String id,
  required String product,
  required PackageType type,
  String price = '€4,99',
  double amount = 4.99,
  String currency = 'EUR',
  String period = 'P1M',
}) => Package(
  id,
  type,
  StoreProduct(
    product,
    '',
    '',
    amount,
    price,
    currency,
    subscriptionPeriod: period,
  ),
  const PresentedOfferingContext('fgi_pro', null, null),
);

final monthly = package(
  id: r'$rc_monthly',
  product: 'fgi.pro.monthly',
  type: PackageType.monthly,
);
final annual = package(
  id: r'$rc_annual',
  product: 'fgi.pro.annual',
  type: PackageType.annual,
  price: '€44,99',
  amount: 44.99,
  period: 'P1Y',
);

Offerings offerings({List<Package>? packages, String id = 'fgi_pro'}) {
  final offering = Offering(id, '', const {}, packages ?? [monthly, annual]);
  return Offerings({
    id: offering,
  }, current: const Offering('default', '', {}, []));
}

CustomerInfo customer({bool pro = false, bool verified = true}) {
  const entitlement = EntitlementInfo(
    RevenueCatService.proEntitlementId,
    true,
    true,
    timestamp,
    timestamp,
    'product',
    false,
  );
  final entries =
      pro
          ? {RevenueCatService.proEntitlementId: entitlement}
          : <String, EntitlementInfo>{};
  return CustomerInfo(
    EntitlementInfos(
      entries,
      entries,
      verification:
          verified
              ? VerificationResult.verified
              : VerificationResult.notRequested,
    ),
    const {},
    const [],
    const [],
    const [],
    timestamp,
    'original-id',
    const {},
    timestamp,
  );
}

class Harness {
  String? user = userA;
  String appUser = userA;
  CustomerInfo info = customer();
  Offerings offered = offerings();
  final requests = Queue<Future<Offerings> Function()>();
  Completer<void>? configurationGate;
  Completer<CustomerInfo>? transactionGate;
  PlatformException? purchaseError;
  bool restoreError = false;
  int offeringCalls = 0;
  int purchaseCalls = 0;
  int restoreCalls = 0;
  int loginCalls = 0;
  Package? purchased;
  final auth = StreamController<String?>.broadcast(sync: true);

  late final RevenueCatService service = RevenueCatService(
    configureSdk: ({required apiKey, appUserId}) async {
      if (configurationGate != null) await configurationGate!.future;
      appUser = appUserId ?? anonymous;
    },
    currentAppUserIdReader: () async => appUser,
    identityLogIn: (id) async {
      loginCalls++;
      appUser = id;
      return null;
    },
    identityLogOut: () async => appUser = anonymous,
    customerInfoReader: () async => info,
    addCustomerInfoListener: (_) {},
    removeCustomerInfoListener: (_) {},
    offeringsReader: () {
      offeringCalls++;
      return requests.isEmpty
          ? Future.value(offered)
          : requests.removeFirst()();
    },
    packagePurchaser: (value) async {
      purchaseCalls++;
      purchased = value;
      if (transactionGate != null) return transactionGate!.future;
      if (purchaseError != null) throw purchaseError!;
      return info;
    },
    purchaseRestorer: () async {
      restoreCalls++;
      if (transactionGate != null) return transactionGate!.future;
      if (restoreError) throw StateError('offline');
      return info;
    },
  );
  late final container = ProviderContainer(
    overrides: [revenueCatServiceProvider.overrideWithValue(service)],
  );
  PurchaseFlowState get state => container.read(purchaseFlowProvider);
  PurchaseFlowNotifier get notifier =>
      container.read(purchaseFlowProvider.notifier);

  void start() {
    service.startIdentitySynchronization(
      authUserIds: auth.stream,
      currentUserId: () => user,
    );
    service.startConfiguration(apiKey: 'appl_test', appUserId: user);
    container.read(purchaseFlowProvider);
  }

  Future<void> settle() async {
    await service.initializationTask;
    await service.identitySynchronizationTask;
    await Future<void>.delayed(Duration.zero);
  }

  void changeUser(String? id) {
    user = id;
    auth.add(id);
  }

  Future<void> dispose() async {
    container.dispose();
    await service.stopIdentitySynchronization();
    await auth.close();
  }
}

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.dispose());

  test(
    'loads fgi_pro, not the current offering, with exact packages and localized prices',
    () async {
      h.start();
      await h.settle();
      expect(h.state.status, OfferingStatus.ready);
      expect(h.state.monthly, monthly);
      expect(h.state.annual, annual);
      expect(
        PriceProvider.monthlyPrice(h.state.monthly?.storeProduct),
        '€4,99/month',
      );
      expect(
        PriceProvider.yearlyPrice(h.state.annual?.storeProduct),
        '€44,99/year',
      );
      expect(
        PriceProvider.annualSavings(monthly.storeProduct, annual.storeProduct),
        24,
      );
      expect(h.offeringCalls, 1);
    },
  );

  test(
    'missing offering, package, and mismatched product are unavailable and retryable',
    () async {
      h.offered = offerings(id: 'default');
      h.start();
      await h.settle();
      expect(h.state.status, OfferingStatus.unavailable);
      h.offered = offerings(packages: [monthly]);
      await h.notifier.retry();
      expect(h.state.status, OfferingStatus.unavailable);
      h.offered = offerings(
        packages: [
          monthly,
          package(
            id: r'$rc_annual',
            product: 'test_store',
            type: PackageType.annual,
          ),
        ],
      );
      await h.notifier.retry();
      expect(h.state.status, OfferingStatus.unavailable);
      h.offered = offerings();
      await h.notifier.retry();
      expect(h.state.status, OfferingStatus.ready);
    },
  );

  test('does not compare prices with incompatible currencies or periods', () {
    final other = package(
      id: r'$rc_annual',
      product: 'fgi.pro.annual',
      type: PackageType.annual,
      currency: 'USD',
      period: 'P1Y',
    );
    expect(
      PriceProvider.annualSavings(monthly.storeProduct, other.storeProduct),
      isNull,
    );
    expect(PriceProvider.monthlyPrice(null), 'Price unavailable');
  });

  test(
    'waits for initialization and rejects signed-out purchase attempts',
    () async {
      h.configurationGate = Completer<void>();
      h.start();
      expect(h.state.status, OfferingStatus.loading);
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.failed,
      );
      expect(h.purchaseCalls, 0);
      h.configurationGate!.complete();
      await h.settle();
      h.changeUser(null);
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.failed,
      );
      expect(h.purchaseCalls, 0);
    },
  );

  for (final plan in SubscriptionPlan.values) {
    test(
      '$plan purchase refreshes and confirms the shared entitlement',
      () async {
        h.start();
        await h.settle();
        h.info = customer(pro: true);
        expect(await h.notifier.purchase(plan), TransactionOutcome.confirmed);
        expect(
          h.purchased,
          plan == SubscriptionPlan.monthly ? monthly : annual,
        );
        expect(
          h.container.read(subscriptionProvider).status,
          SubscriptionStatus.pro,
        );
      },
    );
  }

  test(
    'handles numeric cancellation, pending, failure and unverified success',
    () async {
      h.start();
      await h.settle();
      for (final pair in [
        (
          PurchasesErrorCode.purchaseCancelledError,
          TransactionOutcome.cancelled,
        ),
        (PurchasesErrorCode.paymentPendingError, TransactionOutcome.pending),
        (PurchasesErrorCode.networkError, TransactionOutcome.failed),
      ]) {
        h.purchaseError = PlatformException(code: '${pair.$1.index}');
        expect(await h.notifier.purchase(SubscriptionPlan.monthly), pair.$2);
      }
      h.purchaseError = null;
      h.info = customer(pro: true, verified: false);
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.pending,
      );
      expect(
        h.container.read(subscriptionProvider).status,
        SubscriptionStatus.unavailable,
      );
    },
  );

  test(
    'blocks duplicate transactions and defers identity switching until purchase ends',
    () async {
      h.start();
      await h.settle();
      h.transactionGate = Completer<CustomerInfo>();
      final first = h.notifier.purchase(SubscriptionPlan.monthly);
      expect(h.state.isBusy, isTrue);
      expect(
        await h.notifier.purchase(SubscriptionPlan.annual),
        TransactionOutcome.failed,
      );
      expect(await h.notifier.restore(), TransactionOutcome.failed);
      h.changeUser(userB);
      await Future<void>.delayed(Duration.zero);
      expect(h.loginCalls, 0);
      h.transactionGate!.complete(customer(pro: true));
      expect(await first, TransactionOutcome.identityChanged);
      await h.service.identitySynchronizationTask;
      expect(h.appUser, userB);
      expect(h.purchaseCalls, 1);
    },
  );

  test(
    'restores active, inactive, unverified, and failed transactions',
    () async {
      h.start();
      await h.settle();
      h.info = customer(pro: true);
      expect(await h.notifier.restore(), TransactionOutcome.confirmed);
      h.info = customer();
      expect(await h.notifier.restore(), TransactionOutcome.noEntitlement);
      h.info = customer(pro: true, verified: false);
      expect(await h.notifier.restore(), TransactionOutcome.pending);
      h.restoreError = true;
      expect(await h.notifier.restore(), TransactionOutcome.failed);
    },
  );

  test(
    'ignores a previous account offering response after account switching',
    () async {
      final delayed = Completer<Offerings>();
      h.requests.add(() => delayed.future);
      h.start();
      await h.service.initializationTask;
      await h.service.identitySynchronizationTask;
      await Future<void>.delayed(Duration.zero);
      h.changeUser(userB);
      await h.service.identitySynchronizationTask;
      await Future<void>.delayed(Duration.zero);
      expect(h.state.status, OfferingStatus.ready);
      delayed.complete(offerings(id: 'default'));
      await Future<void>.delayed(Duration.zero);
      expect(h.state.status, OfferingStatus.ready);
      expect(h.state.monthly, monthly);
    },
  );

  test(
    'prevents duplicate restores and rejects results after sign-out',
    () async {
      h.start();
      await h.settle();
      h.transactionGate = Completer<CustomerInfo>();
      final first = h.notifier.restore();
      expect(await h.notifier.restore(), TransactionOutcome.failed);
      h.changeUser(null);
      h.transactionGate!.complete(customer(pro: true));
      expect(await first, TransactionOutcome.identityChanged);
      await h.service.identitySynchronizationTask;
      expect(h.restoreCalls, 1);
      expect(h.appUser, anonymous);
    },
  );

  test(
    'rejects a purchase after switching away and back to the same user',
    () async {
      h.start();
      await h.settle();
      h.transactionGate = Completer<CustomerInfo>();
      final first = h.notifier.purchase(SubscriptionPlan.monthly);
      h.changeUser(userB);
      h.changeUser(userA);
      h.transactionGate!.complete(customer(pro: true));
      expect(await first, TransactionOutcome.identityChanged);
      await h.service.identitySynchronizationTask;
      expect(h.appUser, userA);
      expect(
        h.container.read(subscriptionProvider).status,
        isNot(SubscriptionStatus.pro),
      );
    },
  );

  testWidgets(
    'both purchase screens use store prices and neutral trial wording',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      h.start();
      for (final screen in [const ProPurchase(), const ObProPurchase()]) {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: h.container,
            child: MaterialApp(home: screen),
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(find.text('€4,99/month'), findsOneWidget);
        expect(find.text('€44,99/year'), findsOneWidget);
        expect(find.textContaining('trial', findRichText: true), findsNothing);
        expect(find.text('Subscribe'), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'disposal during purchase does not show a late message or navigate',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      h.start();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: const MaterialApp(home: ProPurchase()),
        ),
      );
      await tester.pump();
      await tester.pump();
      h.transactionGate = Completer<CustomerInfo>();
      await tester.ensureVisible(find.text('Subscribe'));
      await tester.tap(find.text('Subscribe'));
      await tester.pump();
      expect(h.purchaseCalls, 1);
      expect(find.text('Please wait...'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      h.info = customer(pro: true);
      h.transactionGate!.complete(h.info);
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cancelling a purchase leaves the screen without an error', (
    tester,
  ) async {
    h.purchaseError = PlatformException(
      code: '${PurchasesErrorCode.purchaseCancelledError.index}',
    );
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const MaterialApp(home: ProPurchase()),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pump();
    await tester.pump();
    expect(h.purchaseCalls, 1);
    expect(find.byType(ProPurchase), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('onboarding Not Now continues to completion', (tester) async {
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: MaterialApp(
          home: const ObProPurchase(),
          routes: {
            AppRoutes.complete: (_) => const Scaffold(body: Text('Completed')),
          },
        ),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Not Now'));
    await tester.tap(find.text('Not Now'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'signed-out screen explains unavailable purchasing and restoring',
    (tester) async {
      h.user = null;
      h.start();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: const MaterialApp(home: ProPurchase()),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.text('Sign in to purchase or restore subscriptions.'),
        findsOneWidget,
      );
      expect(find.text('Price unavailable'), findsNWidgets(2));
      expect(find.text('Try again'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
