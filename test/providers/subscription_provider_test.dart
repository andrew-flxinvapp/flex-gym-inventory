import 'dart:async';
import 'dart:collection';

import 'package:flex_gym_inventory/providers/subscription_provider.dart';
import 'package:flex_gym_inventory/service/revenuecat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const userA = 'user-a';
const userB = 'user-b';
const anonymous = r'$RCAnonymousID:test';
const proId = 'flex_gym_inventory_pro';
const date = '2026-11-21T00:00:00Z';

CustomerInfo info({
  String? entitlement,
  bool active = false,
  VerificationResult verification = VerificationResult.verified,
}) {
  final entries = <String, EntitlementInfo>{};
  if (entitlement != null) {
    entries[entitlement] = EntitlementInfo(
      entitlement,
      active,
      active,
      date,
      date,
      'product',
      false,
    );
  }
  return CustomerInfo(
    EntitlementInfos(
      entries,
      active ? entries : {},
      verification: verification,
    ),
    const {},
    const [],
    const [],
    const [],
    date,
    'original-may-be-an-alias',
    const {},
    date,
  );
}

class Harness {
  String? userId;
  String appUserId = anonymous;
  bool configurationFails = false;
  bool loginFails = false;
  Completer<void>? configurationGate;
  Completer<void>? loginGate;
  Completer<void>? loginStarted;
  final reads = Queue<Future<CustomerInfo?> Function()>();
  final customerInfo = <String, CustomerInfo?>{};
  final listeners = <CustomerInfoUpdateListener>{};
  CustomerInfo? replayOnRegistration;
  int addCalls = 0;
  int removeCalls = 0;
  int readCalls = 0;
  final auth = StreamController<String?>.broadcast(sync: true);

  late final RevenueCatService service = RevenueCatService(
    configureSdk: ({required apiKey, appUserId}) async {
      if (configurationGate != null) await configurationGate!.future;
      if (configurationFails) throw StateError('configuration failed');
      this.appUserId = appUserId ?? anonymous;
    },
    currentAppUserIdReader: () async => appUserId,
    identityLogIn: (id) async {
      loginStarted?.complete();
      if (loginGate != null) await loginGate!.future;
      if (loginFails) throw StateError('login failed');
      appUserId = id;
      return null;
    },
    identityLogOut: () async => appUserId = anonymous,
    customerInfoReader: () {
      readCalls++;
      if (reads.isNotEmpty) return reads.removeFirst()();
      return Future.value(customerInfo[appUserId]);
    },
    addCustomerInfoListener: (listener) {
      addCalls++;
      listeners.add(listener);
      if (replayOnRegistration != null) listener(replayOnRegistration!);
    },
    removeCustomerInfoListener: (listener) {
      removeCalls++;
      listeners.remove(listener);
    },
  );

  late final ProviderContainer container = ProviderContainer(
    overrides: [revenueCatServiceProvider.overrideWithValue(service)],
  );

  SubscriptionState get state => container.read(subscriptionProvider);
  SubscriptionNotifier get notifier =>
      container.read(subscriptionProvider.notifier);

  void listen() => service.startIdentitySynchronization(
    authUserIds: auth.stream,
    currentUserId: () => userId,
  );

  void configure() =>
      service.startConfiguration(apiKey: 'appl_test', appUserId: userId);

  void changeUser(String? value) {
    userId = value;
    auth.add(value);
  }

  void emit(CustomerInfo value) {
    for (final listener in listeners.toList()) {
      listener(value);
    }
  }

  Future<void> settle() async {
    await service.initializationTask;
    await service.identitySynchronizationTask;
    await notifier.refresh();
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
    'loads and recognizes only the configured active PRO entitlement',
    () async {
      h.userId = userA;
      h.customerInfo[userA] = info(entitlement: 'pro', active: true);
      h.listen();
      expect(h.state.status, SubscriptionStatus.loading);
      h.configure();
      await h.settle();
      expect(h.state.status, SubscriptionStatus.free);
      expect(await h.service.hasProEntitlement(), isFalse);

      h.customerInfo[userA] = info(entitlement: proId, active: true);
      await h.notifier.refresh();
      expect(h.state.status, SubscriptionStatus.pro);
      expect(await h.service.hasProEntitlement(), isTrue);
      expect(h.state.customerInfoRequestedAt, DateTime.parse(date));

      h.customerInfo[userA] = info(entitlement: proId);
      await h.notifier.refresh();
      expect(h.state.status, SubscriptionStatus.free);
    },
  );

  test(
    'waits for delayed configuration and identity synchronization',
    () async {
      h.userId = userA;
      h.configurationGate = Completer<void>();
      h.customerInfo[userA] = info(entitlement: proId, active: true);
      h.listen();
      h.configure();
      expect(h.state.status, SubscriptionStatus.loading);
      expect(h.readCalls, 0);
      h.configurationGate!.complete();
      await h.settle();
      expect(h.state.status, SubscriptionStatus.pro);
    },
  );

  test('recovers when configuration succeeds after its timeout', () async {
    h.userId = userA;
    h.configurationGate = Completer<void>();
    h.customerInfo[userA] = info(entitlement: proId, active: true);
    h.listen();
    expect(h.state.status, SubscriptionStatus.loading);
    h.service.startConfiguration(
      apiKey: 'appl_test',
      appUserId: userA,
      timeout: const Duration(milliseconds: 10),
    );
    await h.service.initializationTask;
    expect(h.state.status, SubscriptionStatus.unavailable);
    h.configurationGate!.complete();
    await Future<void>.delayed(Duration.zero);
    await h.service.identitySynchronizationTask;
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.pro);
  });

  test(
    'initialization and identity failures are unavailable, not free',
    () async {
      h.userId = userA;
      h.configurationFails = true;
      h.listen();
      h.configure();
      await h.settle();
      expect(h.state.status, SubscriptionStatus.unavailable);
      expect(h.readCalls, 0);
    },
  );

  test(
    'identity failure does not read or publish customer information',
    () async {
      h.listen();
      h.configure();
      await h.settle();
      h.loginFails = true;
      h.changeUser(userA);
      await h.service.identitySynchronizationTask;
      expect(h.state.status, SubscriptionStatus.unavailable);
      expect(h.readCalls, 0);
    },
  );

  test('refresh failure retains last known PRO and can recover', () async {
    h.userId = userA;
    h.customerInfo[userA] = info(entitlement: proId, active: true);
    h.listen();
    h.configure();
    await h.settle();
    h.reads.add(() async => throw StateError('offline'));
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.unavailable);
    expect(h.state.lastKnownStatus, SubscriptionStatus.pro);
    h.customerInfo[userA] = info();
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.free);
    expect(h.state.lastKnownStatus, SubscriptionStatus.free);
  });

  test('missing customer information is unavailable', () async {
    h.userId = userA;
    h.listen();
    h.configure();
    await h.settle();
    expect(h.state.status, SubscriptionStatus.unavailable);
    expect(h.state.lastKnownStatus, isNull);
    await expectLater(h.service.hasProEntitlement(), throwsStateError);
  });

  test('unverified or failed cached entitlements are not confirmed', () async {
    h.userId = userA;
    h.customerInfo[userA] = info(
      entitlement: proId,
      active: true,
      verification: VerificationResult.notRequested,
    );
    h.listen();
    h.configure();
    await h.settle();
    expect(h.state.status, SubscriptionStatus.unavailable);
    expect(h.state.lastKnownStatus, isNull);
    await expectLater(h.service.hasProEntitlement(), throwsStateError);

    h.customerInfo[userA] = info(verification: VerificationResult.failed);
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.unavailable);

    h.customerInfo[userA] = info(
      entitlement: proId,
      active: true,
      verification: VerificationResult.verifiedOnDevice,
    );
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.pro);
  });

  test(
    'verified cached information can be used without a network response',
    () async {
      h.userId = userA;
      h.customerInfo[userA] = info(entitlement: proId, active: true);
      h.listen();
      h.configure();
      await h.settle();
      expect(h.state.status, SubscriptionStatus.pro);
      expect(h.state.customerInfoRequestedAt, DateTime.parse(date));
    },
  );

  test(
    'listener refreshes current info and ignores replay and duplicate events',
    () async {
      h.userId = userA;
      h.customerInfo[userA] = info();
      h.replayOnRegistration = info(entitlement: proId, active: true);
      h.listen();
      h.configure();
      await h.settle();
      expect(h.state.status, SubscriptionStatus.free);
      expect(h.addCalls, 1);
      expect(h.readCalls, 1);

      final pro = info(entitlement: proId, active: true);
      h.customerInfo[userA] = pro;
      h.emit(pro);
      await h.notifier.refresh();
      expect(h.state.status, SubscriptionStatus.pro);
      expect(h.readCalls, 2);
      h.emit(pro);
      await Future<void>.delayed(Duration.zero);
      expect(h.readCalls, 2);
      expect(h.addCalls, 1);
    },
  );

  test(
    'updates arriving during a fetch cannot be overwritten by its result',
    () async {
      h.userId = userA;
      h.customerInfo[userA] = info();
      h.listen();
      h.configure();
      await h.settle();
      final delayed = Completer<CustomerInfo?>();
      h.reads.add(() => delayed.future);
      final refresh = h.notifier.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(h.state.status, SubscriptionStatus.free);
      expect(h.state.isRefreshing, isTrue);
      final pro = info(entitlement: proId, active: true);
      h.customerInfo[userA] = pro;
      h.emit(pro);
      delayed.complete(info());
      await refresh;
      expect(h.state.status, SubscriptionStatus.pro);
      expect(h.state.isRefreshing, isFalse);
      expect(h.readCalls, 3);
    },
  );

  test(
    'sign-out immediately clears prior status even if logout is pending',
    () async {
      h.userId = userA;
      h.customerInfo[userA] = info(entitlement: proId, active: true);
      h.listen();
      h.configure();
      await h.settle();
      h.changeUser(null);
      expect(h.state.status, SubscriptionStatus.signedOut);
      expect(h.state.lastKnownStatus, isNull);
    },
  );

  test('account switches discard old status and late responses', () async {
    h.userId = userA;
    h.customerInfo[userA] = info(entitlement: proId, active: true);
    h.customerInfo[userB] = info();
    h.listen();
    h.configure();
    await h.settle();
    final delayed = Completer<CustomerInfo?>();
    h.reads.add(() => delayed.future);
    final oldRefresh = h.notifier.refresh();
    await Future<void>.delayed(Duration.zero);
    h.changeUser(userB);
    expect(h.state.status, SubscriptionStatus.loading);
    expect(h.state.lastKnownStatus, isNull);
    await h.service.identitySynchronizationTask;
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.free);
    delayed.complete(info(entitlement: proId, active: true));
    await oldRefresh;
    expect(h.state.status, SubscriptionStatus.free);
    expect(h.addCalls, 1);
    h.emit(info(entitlement: proId, active: true));
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.free);
  });

  test('refresh rechecks auth even before its stream event arrives', () async {
    h.userId = userA;
    h.customerInfo[userA] = info(entitlement: proId, active: true);
    h.listen();
    h.configure();
    await h.settle();

    h.userId = userB;
    await h.notifier.refresh();
    expect(h.state.status, SubscriptionStatus.loading);
    expect(h.state.lastKnownStatus, isNull);
  });

  test(
    'identity change during refresh notification cannot strand the new request',
    () async {
      h.userId = userA;
      h.customerInfo[userA] = info(entitlement: proId, active: true);
      h.customerInfo[userB] = info();
      h.listen();
      h.configure();
      await h.settle();
      var changed = false;
      final subscription = h.container.listen(subscriptionProvider, (_, next) {
        if (next.isRefreshing && !changed) {
          changed = true;
          h.changeUser(userB);
        }
      });
      addTearDown(subscription.close);

      final oldRefresh = h.notifier.refresh();
      await h.service.identitySynchronizationTask;
      await h.notifier.refresh();
      await oldRefresh;
      expect(h.state.status, SubscriptionStatus.free);
      expect(h.state.isRefreshing, isFalse);
    },
  );

  test(
    'rapid auth changes do not publish superseded account information',
    () async {
      h.listen();
      h.configure();
      await h.settle();
      h.customerInfo[userB] = info();
      h.loginGate = Completer<void>();
      h.loginStarted = Completer<void>();
      h.changeUser(userA);
      await h.loginStarted!.future;
      h.loginStarted = null;
      h.changeUser(userB);
      expect(h.state.status, SubscriptionStatus.loading);
      h.loginGate!.complete();
      await h.service.identitySynchronizationTask;
      await h.notifier.refresh();
      expect(h.appUserId, userB);
      expect(h.state.status, SubscriptionStatus.free);
    },
  );

  test(
    'disposal removes listener and ignores late customer responses',
    () async {
      h.userId = userA;
      h.customerInfo[userA] = info();
      h.listen();
      h.configure();
      await h.settle();
      final delayed = Completer<CustomerInfo?>();
      h.reads.add(() => delayed.future);
      final refresh = h.notifier.refresh();
      await Future<void>.delayed(Duration.zero);
      h.container.dispose();
      expect(h.removeCalls, 1);
      expect(h.listeners, isEmpty);
      delayed.complete(info(entitlement: proId, active: true));
      await refresh;
    },
  );
}
