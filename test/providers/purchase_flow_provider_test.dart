import 'dart:async';
import 'dart:collection';

import 'package:flex_gym_inventory/providers/purchase_flow_provider.dart';
import 'package:flex_gym_inventory/providers/subscription_provider.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/service/revenuecat_service.dart';
import 'package:flex_gym_inventory/src/providers/price_provider.dart';
import 'package:flex_gym_inventory/src/screens/ob_pro_purchase.dart';
import 'package:flex_gym_inventory/src/screens/pro_purchase.dart';
import 'package:flex_gym_inventory/src/widgets/snackbar.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
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
  Completer<CustomerInfo?>? customerInfoGate;
  void Function()? onPurchase;
  CustomerInfoUpdateListener? customerInfoListener;
  PlatformException? purchaseError;
  bool restoreError = false;
  String restoreErrorMessage = 'offline';
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
    customerInfoReader: () async => customerInfoGate?.future ?? info,
    addCustomerInfoListener: (listener) => customerInfoListener = listener,
    removeCustomerInfoListener: (_) => customerInfoListener = null,
    offeringsReader: () {
      offeringCalls++;
      return requests.isEmpty
          ? Future.value(offered)
          : requests.removeFirst()();
    },
    packagePurchaser: (value) async {
      purchaseCalls++;
      purchased = value;
      onPurchase?.call();
      if (transactionGate != null) return transactionGate!.future;
      if (purchaseError != null) throw purchaseError!;
      return info;
    },
    purchaseRestorer: () async {
      restoreCalls++;
      if (transactionGate != null) return transactionGate!.future;
      if (restoreError) throw StateError(restoreErrorMessage);
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
    'logs offering success once only after full package validation',
    () async {
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final messages = <String>[];
      final subscription = Logger.root.onRecord.listen((record) {
        if (record.message.startsWith('RevenueCatService:')) {
          messages.add(record.message);
        }
      });
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
      });

      h.start();
      await h.settle();
      expect(h.state.status, OfferingStatus.ready);
      expect(
        messages.where(
          (message) =>
              message.contains("Offering 'fgi_pro' loaded successfully."),
        ),
        hasLength(1),
      );
      expect(
        messages.where(
          (message) =>
              message.contains('Monthly and annual packages verified.'),
        ),
        hasLength(1),
      );

      await h.notifier.retry();
      expect(
        messages.where((message) => message.contains('loaded successfully')),
        hasLength(1),
      );
    },
  );

  test('missing and mismatched packages never log success', () async {
    final previousLevel = Logger.root.level;
    Logger.root.level = Level.ALL;
    final messages = <String>[];
    final subscription = Logger.root.onRecord.listen((record) {
      if (record.message.startsWith('RevenueCatService:')) {
        messages.add(record.message);
      }
    });
    addTearDown(() async {
      await subscription.cancel();
      Logger.root.level = previousLevel;
    });

    h.offered = offerings(packages: [monthly]);
    h.start();
    await h.settle();
    expect(h.state.status, OfferingStatus.unavailable);
    expect(
      messages.where((message) => message.contains('loaded successfully')),
      isEmpty,
    );
    expect(
      messages.any(
        (message) => message.contains('Monthly or annual package is missing'),
      ),
      isTrue,
    );

    messages.clear();
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
    expect(
      messages.where((message) => message.contains('loaded successfully')),
      isEmpty,
    );
    expect(
      messages.any(
        (message) => message.contains('App Store product ID is mismatched'),
      ),
      isTrue,
    );
  });

  test('retrieval diagnostics do not expose account information', () async {
    final previousLevel = Logger.root.level;
    Logger.root.level = Level.ALL;
    final messages = <String>[];
    final subscription = Logger.root.onRecord.listen((record) {
      messages.add(record.message);
    });
    addTearDown(() async {
      await subscription.cancel();
      Logger.root.level = previousLevel;
    });

    h.requests.add(
      () async =>
          throw PlatformException(
            code: 'configuration_error',
            message: 'secret:${h.appUser}',
          ),
    );
    h.start();
    await h.settle();

    expect(h.state.status, OfferingStatus.unavailable);
    expect(
      messages.any(
        (message) => message.contains('StoreKit or SDK configuration error'),
      ),
      isTrue,
    );
    expect(messages.join('\n'), isNot(contains(h.appUser)));
    expect(messages.join('\n'), isNot(contains(userA)));
  });

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
        h.onPurchase = () => h.info = customer(pro: true);
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
    'transaction diagnostics report safe outcomes without SDK payloads',
    () async {
      const signedData = 'eyJhbGciOiJFUzI1Ni.fake-signature';
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final records = <LogRecord>[];
      final subscription = Logger.root.onRecord.listen(records.add);
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
      });

      h.start();
      await h.settle();
      for (final error in [
        PurchasesErrorCode.purchaseCancelledError,
        PurchasesErrorCode.paymentPendingError,
        PurchasesErrorCode.storeProblemError,
      ]) {
        h.purchaseError = PlatformException(
          code: '${error.index}',
          message: '$signedData $userA',
          details: signedData,
        );
        await h.notifier.purchase(SubscriptionPlan.monthly);
      }
      h.purchaseError = null;
      h.onPurchase = () => h.info = customer(pro: true);
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.confirmed,
      );
      expect(await h.notifier.restore(), TransactionOutcome.confirmed);
      h.restoreError = true;
      h.restoreErrorMessage = '$signedData $userA';
      expect(await h.notifier.restore(), TransactionOutcome.failed);

      final output = records
          .map((record) => '${record.message} ${record.error}')
          .join('\n');
      expect(output, contains('Purchase requested.'));
      expect(output, contains('Purchase outcome: cancelled.'));
      expect(output, contains('Purchase outcome: pending.'));
      expect(output, contains('Purchase outcome: failed.'));
      expect(output, contains('Purchase failed: store error.'));
      expect(
        output,
        contains('Purchase completed and PRO entitlement verified.'),
      );
      expect(
        output,
        contains('Restore completed and PRO entitlement verified.'),
      );
      expect(output, contains('Restore outcome: failed.'));
      expect(output, isNot(contains(signedData)));
      expect(output, isNot(contains(userA)));

      records.clear();
      Logger.root.level = Level.INFO;
      await h.notifier.restore();
      expect(
        records.where(
          (record) => record.message.startsWith('PurchaseFlow: Restore'),
        ),
        isEmpty,
      );
      expect(records.any((record) => record.level >= Level.WARNING), isTrue);
    },
  );

  test(
    'verified PRO and a refreshed stale Free state prevent purchases',
    () async {
      h.start();
      await h.settle();
      await h.container.read(subscriptionProvider.notifier).refresh();
      expect(
        h.container.read(subscriptionProvider).status,
        SubscriptionStatus.free,
      );
      h.info = customer(pro: true);
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.alreadyPro,
      );
      expect(
        await h.notifier.purchase(SubscriptionPlan.annual),
        TransactionOutcome.alreadyPro,
      );
      expect(h.purchaseCalls, 0);
      expect(h.state.isBusy, isFalse);
    },
  );

  test(
    'unavailable status blocks purchase but permits retry after recovery',
    () async {
      h.info = customer(verified: false);
      h.start();
      await h.settle();
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.subscriptionUnavailable,
      );
      expect(
        h.container.read(subscriptionProvider).status,
        SubscriptionStatus.unavailable,
      );
      expect(h.purchaseCalls, 0);
      expect(h.state.isBusy, isFalse);
      h.info = customer();
      h.purchaseError = PlatformException(
        code: '${PurchasesErrorCode.purchaseCancelledError.index}',
      );
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.cancelled,
      );
      expect(h.purchaseCalls, 1);
    },
  );

  test(
    'refresh permits purchase after a previously active entitlement expires',
    () async {
      h.info = customer(pro: true);
      h.start();
      await h.settle();
      await h.container.read(subscriptionProvider.notifier).refresh();
      expect(
        h.container.read(subscriptionProvider).status,
        SubscriptionStatus.pro,
      );
      h.info = customer();
      h.onPurchase = () => h.info = customer(pro: true);
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.confirmed,
      );
      expect(h.purchaseCalls, 1);
    },
  );

  test(
    'pending preflight waits for verification and rejects account changes',
    () async {
      h.start();
      await h.settle();
      h.customerInfoGate = Completer<CustomerInfo?>();
      final pending = h.notifier.purchase(SubscriptionPlan.monthly);
      await Future<void>.delayed(Duration.zero);
      expect(
        h.container.read(subscriptionProvider).status,
        SubscriptionStatus.loading,
      );
      expect(h.purchaseCalls, 0);
      h.changeUser(userB);
      h.customerInfoGate!.complete(customer());
      expect(await pending, TransactionOutcome.identityChanged);
      expect(h.purchaseCalls, 0);
    },
  );

  test(
    'already purchased SDK error refreshes without claiming a new purchase',
    () async {
      h.start();
      await h.settle();
      h.purchaseError = PlatformException(
        code: '${PurchasesErrorCode.productAlreadyPurchasedError.index}',
      );
      h.onPurchase = () => h.info = customer(pro: true);
      expect(
        await h.notifier.purchase(SubscriptionPlan.monthly),
        TransactionOutcome.alreadyPro,
      );
      expect(h.purchaseCalls, 1);
      expect(
        h.container.read(subscriptionProvider).status,
        SubscriptionStatus.pro,
      );
    },
  );

  test(
    'already purchased SDK error without verified PRO remains pending',
    () async {
      h.start();
      await h.settle();
      h.purchaseError = PlatformException(
        code: '${PurchasesErrorCode.productAlreadyPurchasedError.index}',
      );
      h.onPurchase = () => h.info = customer(pro: true, verified: false);
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
      h.onPurchase = () => h.info = customer(pro: true, verified: false);
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
      await Future<void>.delayed(Duration.zero);
      expect(h.purchaseCalls, 1);
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
      await Future<void>.delayed(Duration.zero);
      expect(h.purchaseCalls, 1);
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

  for (final onboarding in [false, true]) {
    testWidgets(
      '${onboarding ? 'onboarding' : 'regular'} existing PRO shows information without StoreKit',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        h.info = customer(pro: true);
        h.start();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: h.container,
            child: MaterialApp(
              home: onboarding ? const ObProPurchase() : const ProPurchase(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Subscribe'));
        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(h.purchaseCalls, 0);
        expect(find.text('Welcome to FGI PRO!'), findsNothing);
        expect(
          find.text('This account already has an active PRO subscription.'),
          findsOneWidget,
        );
        final snackbar = tester.widget<FlexSnackbar>(find.byType(FlexSnackbar));
        expect(snackbar.type, SnackbarType.update);
        expect(snackbar.multiline, isTrue);
        expect(tester.getTopLeft(find.byType(FlexSnackbar)).dy, 36);
        expect(
          tester
              .widget<Text>(
                find.text(
                  'This account already has an active PRO subscription.',
                ),
              )
              .maxLines,
          isNull,
        );
        expect(find.byType(SnackBar), findsNothing);
        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(FlexSnackbar), findsOneWidget);
        await tester.ensureVisible(find.text('Restore Purchases'));
        await tester.tap(find.text('Restore Purchases'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(FlexSnackbar), findsOneWidget);
        expect(find.text('PRO subscription is active.'), findsOneWidget);
        expect(
          tester.widget<FlexSnackbar>(find.byType(FlexSnackbar)).type,
          SnackbarType.success,
        );
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.byType(FlexSnackbar), findsNothing);
        await tester.ensureVisible(find.text('Subscribe'));
        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(FlexSnackbar), findsOneWidget);
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        expect(find.byType(FlexSnackbar), findsNothing);
        expect(find.text('Subscribe'), findsOneWidget);
        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        expect(find.byType(FlexSnackbar), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 4));
        expect(find.byType(FlexSnackbar), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    for (final outcome in ['cancelled', 'failed', 'pending', 'unresolved']) {
      testWidgets(
        '${onboarding ? 'onboarding' : 'regular'} purchase retains primary styling until $outcome',
        (tester) async {
          tester.view.physicalSize = const Size(400, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          h.start();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: h.container,
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                home: onboarding ? const ObProPurchase() : const ProPurchase(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final enabledFinder = find.ancestor(
            of: find.text('Subscribe'),
            matching: find.byType(ElevatedButton),
          );
          await tester.ensureVisible(enabledFinder);
          final enabled = tester.widget<ElevatedButton>(enabledFinder);
          final enabledSize = tester.getSize(enabledFinder);
          final enabledText = tester.widget<Text>(find.text('Subscribe'));
          final enabledBackground = enabled.style!.backgroundColor!.resolve({});
          final enabledForeground = enabled.style!.foregroundColor!.resolve({});
          final enabledShape = enabled.style!.shape!.resolve({});
          expect(enabled.onPressed, isNotNull);

          h.transactionGate = Completer<CustomerInfo>();
          await tester.tap(enabledFinder);
          await tester.pumpAndSettle();
          final busyFinder = find.ancestor(
            of: find.text('Please wait...'),
            matching: find.byType(ElevatedButton),
          );
          final busy = tester.widget<ElevatedButton>(busyFinder);
          expect(busy.onPressed, isNull);
          expect(tester.getSize(busyFinder), enabledSize);
          expect(
            tester.widget<Text>(find.text('Please wait...')).style,
            enabledText.style,
          );
          expect(
            busy.style!.backgroundColor!.resolve({WidgetState.disabled}),
            enabledBackground,
          );
          expect(
            busy.style!.foregroundColor!.resolve({WidgetState.disabled}),
            enabledForeground,
          );
          expect(
            busy.style!.shape!.resolve({WidgetState.disabled}),
            enabledShape,
          );
          await tester.tap(busyFinder);
          await tester.pump();
          expect(h.purchaseCalls, 1);

          if (outcome == 'unresolved') {
            h.transactionGate!.complete(customer());
          } else {
            final error = switch (outcome) {
              'cancelled' => PurchasesErrorCode.purchaseCancelledError,
              'pending' => PurchasesErrorCode.paymentPendingError,
              _ => PurchasesErrorCode.networkError,
            };
            h.transactionGate!.completeError(
              PlatformException(code: '${error.index}'),
            );
          }
          await tester.pumpAndSettle();
          final restoredFinder = find.ancestor(
            of: find.text('Subscribe'),
            matching: find.byType(ElevatedButton),
          );
          expect(
            tester.widget<ElevatedButton>(restoredFinder).onPressed,
            isNotNull,
          );
          expect(find.text('Welcome to FGI PRO!'), findsNothing);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

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
    expect(find.byType(FlexSnackbar), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('already purchased store response does not show welcome', (
    tester,
  ) async {
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const MaterialApp(home: ProPurchase()),
      ),
    );
    await tester.pumpAndSettle();
    h.purchaseError = PlatformException(
      code: '${PurchasesErrorCode.productAlreadyPurchasedError.index}',
    );
    h.onPurchase = () => h.info = customer(pro: true);
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(h.purchaseCalls, 1);
    expect(find.text('Welcome to FGI PRO!'), findsNothing);
    expect(
      find.text('This account already has an active PRO subscription.'),
      findsOneWidget,
    );
    expect(find.text('Subscribe'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'unavailable preflight provides retry feedback without purchasing',
    (tester) async {
      h.info = customer(verified: false);
      h.start();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: const MaterialApp(home: ProPurchase()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Subscribe'));
      await tester.tap(find.text('Subscribe'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(h.purchaseCalls, 0);
      expect(
        find.text(
          'Subscription status could not be verified. Please try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome to FGI PRO!'), findsNothing);
      expect(find.text('Subscribe'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('verified purchase waits for Continue and returns to origin', (
    tester,
  ) async {
    h.start();
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('Origin')),
          routes: {
            AppRoutes.upgradeInfo: (_) => const Scaffold(body: Text('Upgrade')),
            AppRoutes.proPurchase: (_) => const ProPurchase(),
          },
        ),
      ),
    );
    navigatorKey.currentState!.pushNamed(AppRoutes.upgradeInfo);
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pushNamed(AppRoutes.proPurchase);
    await tester.pumpAndSettle();
    h.onPurchase = () => h.info = customer(pro: true);
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to FGI PRO!'), findsOneWidget);
    expect(find.byType(ProPurchase), findsOneWidget);
    h.customerInfoListener!(h.info);
    h.customerInfoListener!(h.info);
    await h.container.read(subscriptionProvider.notifier).refresh();
    await tester.pump();
    expect(find.text('Welcome to FGI PRO!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Origin'), findsOneWidget);
    expect(find.text('Welcome to FGI PRO!'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('verified onboarding purchase continues to completion', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();
    h.onPurchase = () => h.info = customer(pro: true);
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to FGI PRO!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('success waits for delayed entitlement verification', (
    tester,
  ) async {
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const MaterialApp(home: ProPurchase()),
      ),
    );
    await tester.pumpAndSettle();
    h.onPurchase = () {
      h.info = customer(pro: true);
      h.customerInfoGate = Completer<CustomerInfo?>();
    };
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pump();
    expect(find.text('Welcome to FGI PRO!'), findsNothing);
    h.customerInfoGate!.complete(h.info);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to FGI PRO!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disposal during entitlement verification prevents the dialog', (
    tester,
  ) async {
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const MaterialApp(home: ProPurchase()),
      ),
    );
    await tester.pumpAndSettle();
    h.onPurchase = () {
      h.info = customer(pro: true);
      h.customerInfoGate = Completer<CustomerInfo?>();
    };
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    h.customerInfoGate!.complete(h.info);
    await tester.pump();
    await tester.pump();
    expect(find.text('Welcome to FGI PRO!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in ['free', 'unverified', 'pending', 'failed']) {
    testWidgets('$scenario purchase does not show success', (tester) async {
      h.start();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: const MaterialApp(home: ProPurchase()),
        ),
      );
      await tester.pumpAndSettle();
      if (scenario == 'unverified') {
        h.onPurchase = () => h.info = customer(pro: true, verified: false);
      }
      if (scenario == 'pending') {
        h.purchaseError = PlatformException(
          code: '${PurchasesErrorCode.paymentPendingError.index}',
        );
      }
      if (scenario == 'failed') {
        h.purchaseError = PlatformException(
          code: '${PurchasesErrorCode.networkError.index}',
        );
      }
      await tester.ensureVisible(find.text('Subscribe'));
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to FGI PRO!'), findsNothing);
      expect(find.byType(ProPurchase), findsOneWidget);
      expect(find.byType(FlexSnackbar), findsOneWidget);
      expect(
        tester.widget<FlexSnackbar>(find.byType(FlexSnackbar)).type,
        scenario == 'failed' ? SnackbarType.stop : SnackbarType.update,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('account change during purchase prevents success dialog', (
    tester,
  ) async {
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const MaterialApp(home: ProPurchase()),
      ),
    );
    await tester.pumpAndSettle();
    h.transactionGate = Completer<CustomerInfo>();
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pump();
    h.changeUser(userB);
    h.transactionGate!.complete(customer(pro: true));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to FGI PRO!'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('account change dismisses the dialog and prevents navigation', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();
    h.onPurchase = () => h.info = customer(pro: true);
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to FGI PRO!'), findsOneWidget);
    h.changeUser(userB);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to FGI PRO!'), findsNothing);
    expect(find.text('Completed'), findsNothing);
    expect(find.textContaining('Your account changed.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('restore keeps its existing feedback without purchase dialog', (
    tester,
  ) async {
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const MaterialApp(home: ProPurchase()),
      ),
    );
    await tester.pumpAndSettle();
    h.info = customer(pro: true);
    await tester.ensureVisible(find.text('Restore Purchases'));
    await tester.tap(find.text('Restore Purchases'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(h.restoreCalls, 1);
    expect(find.text('Welcome to FGI PRO!'), findsNothing);
    expect(find.text('PRO subscription is active.'), findsOneWidget);
    expect(
      tester.widget<FlexSnackbar>(find.byType(FlexSnackbar)).type,
      SnackbarType.success,
    );
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
