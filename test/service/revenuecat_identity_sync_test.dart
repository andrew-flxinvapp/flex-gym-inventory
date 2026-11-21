import 'dart:async';

import 'package:flex_gym_inventory/service/revenuecat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

const _anonymousId = r'$RCAnonymousID:test';
const _userA = '3b6b942f-48e8-47d1-84a4-87c69be4f3af';
const _userB = 'cf667c79-b947-428d-a340-0986db8fe65c';

class _FakeRevenueCatSdk {
  String appUserId = _anonymousId;
  final List<String> loginUserIds = [];
  int logoutCalls = 0;
  int customerInfoCalls = 0;
  int loginFailuresRemaining = 0;
  int logoutFailuresRemaining = 0;
  bool failConfiguration = false;
  Completer<void>? configurationGate;
  Completer<void>? nextLoginGate;
  Completer<void>? loginStarted;

  Future<void> configure({required String apiKey, String? appUserId}) async {
    final gate = configurationGate;
    if (gate != null) await gate.future;
    if (failConfiguration) throw StateError('configuration failed');
    this.appUserId = appUserId ?? _anonymousId;
  }

  Future<String> readAppUserId() async => appUserId;

  Future<Null> logIn(String appUserId) async {
    loginUserIds.add(appUserId);
    final started = loginStarted;
    if (started != null && !started.isCompleted) started.complete();
    final gate = nextLoginGate;
    nextLoginGate = null;
    if (gate != null) await gate.future;
    if (loginFailuresRemaining > 0) {
      loginFailuresRemaining--;
      throw StateError('login failed');
    }
    this.appUserId = appUserId;
    return null;
  }

  Future<void> logOut() async {
    logoutCalls++;
    if (logoutFailuresRemaining > 0) {
      logoutFailuresRemaining--;
      throw StateError('logout failed');
    }
    appUserId = _anonymousId;
  }

  Future<Null> getCustomerInfo() async {
    customerInfoCalls++;
    return null;
  }
}

class _Harness {
  final _FakeRevenueCatSdk sdk = _FakeRevenueCatSdk();
  final StreamController<String?> authEvents =
      StreamController<String?>.broadcast(sync: true);
  String? supabaseUserId;
  late final RevenueCatService service = RevenueCatService(
    configureSdk: sdk.configure,
    currentAppUserIdReader: sdk.readAppUserId,
    identityLogIn: sdk.logIn,
    identityLogOut: sdk.logOut,
    customerInfoReader: sdk.getCustomerInfo,
  );

  void listenForAuthChanges() {
    service.startIdentitySynchronization(
      authUserIds: authEvents.stream,
      currentUserId: () => supabaseUserId,
    );
  }

  void configure({String? initialAppUserId}) {
    service.startConfiguration(
      apiKey: 'appl_test_key',
      appUserId: initialAppUserId,
    );
  }

  Future<void> settle() async {
    await service.initializationTask;
    await service.identitySynchronizationTask;
  }

  void changeUser(String? userId) {
    supabaseUserId = userId;
    authEvents.add(userId);
  }

  Future<void> dispose() async {
    await service.stopIdentitySynchronization();
    await authEvents.close();
  }
}

void main() {
  group('RevenueCat identity synchronization', () {
    late _Harness harness;

    setUp(() {
      harness = _Harness();
    });

    tearDown(() async {
      await harness.dispose();
    });

    test('logs only validated identity transitions without identifiers', () async {
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final messages = <String>[];
      final subscription = Logger.root.onRecord.listen((record) {
        if (record.message.startsWith(
          'RevenueCatIdentity: RevenueCat identity synchronized',
        )) {
          messages.add(record.message);
        }
      });
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
      });

      const signedOut =
          'RevenueCatIdentity: RevenueCat identity synchronized for signed-out Supabase session.';
      const authenticated =
          'RevenueCatIdentity: RevenueCat identity synchronized for authenticated Supabase session.';

      harness.listenForAuthChanges();
      harness.configure();
      await harness.settle();
      expect(messages, [signedOut]);

      final loginGate = Completer<void>();
      harness.sdk.nextLoginGate = loginGate;
      harness.sdk.loginStarted = Completer<void>();
      harness.changeUser(_userA);
      await harness.sdk.loginStarted!.future;
      expect(messages, [signedOut]);
      loginGate.complete();
      await harness.service.identitySynchronizationTask;
      expect(messages, [signedOut, authenticated]);

      harness.changeUser(_userA);
      await harness.service.identitySynchronizationTask;
      expect(messages, [signedOut, authenticated]);

      harness.changeUser(_userB);
      await harness.service.identitySynchronizationTask;
      harness.changeUser(null);
      await harness.service.identitySynchronizationTask;
      harness.changeUser(null);
      await harness.service.identitySynchronizationTask;
      expect(messages, [signedOut, authenticated, authenticated, signedOut]);
    });

    test(
      'does not log identity success after failed synchronization',
      () async {
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

        harness.listenForAuthChanges();
        harness.configure();
        await harness.settle();
        messages.clear();

        harness.sdk.loginFailuresRemaining = 2;
        harness.changeUser(_userA);
        await harness.service.identitySynchronizationTask;

        expect(
          messages.where(
            (message) => message.contains('identity synchronized for'),
          ),
          isEmpty,
        );
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.failed,
        );
      },
    );

    test('identifies an authenticated user during SDK configuration', () async {
      harness.supabaseUserId = _userA;
      harness.listenForAuthChanges();
      harness.configure(initialAppUserId: _userA);
      await harness.settle();

      expect(harness.sdk.appUserId, _userA);
      expect(harness.sdk.loginUserIds, isEmpty);
      expect(
        harness.service.identityState.value.status,
        RevenueCatIdentityStatus.synchronized,
      );
      expect(harness.service.isCurrentSupabaseUserSynchronized, isTrue);
    });

    test(
      'syncs auth that arrives while RevenueCat initialization is pending',
      () async {
        harness.sdk.configurationGate = Completer<void>();
        harness.listenForAuthChanges();
        harness.configure();

        harness.changeUser(_userA);
        expect(harness.sdk.loginUserIds, isEmpty);

        harness.sdk.configurationGate!.complete();
        await harness.settle();

        expect(harness.sdk.loginUserIds, [_userA]);
        expect(harness.sdk.appUserId, _userA);
      },
    );

    test(
      'syncs a Supabase sign-in after RevenueCat is already configured',
      () async {
        harness.listenForAuthChanges();
        harness.configure();
        await harness.settle();

        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.signedOut,
        );
        expect(harness.sdk.logoutCalls, 0);

        harness.changeUser(_userA);
        await harness.service.identitySynchronizationTask;

        expect(harness.sdk.loginUserIds, [_userA]);
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.synchronized,
        );
      },
    );

    test(
      'sign-out logs out RevenueCat without blocking auth state changes',
      () async {
        harness.supabaseUserId = _userA;
        harness.listenForAuthChanges();
        harness.configure(initialAppUserId: _userA);
        await harness.settle();

        harness.changeUser(null);
        expect(harness.supabaseUserId, isNull);
        await harness.service.identitySynchronizationTask;

        expect(harness.sdk.logoutCalls, 1);
        expect(harness.sdk.appUserId, _anonymousId);
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.signedOut,
        );
        expect(harness.service.isCurrentSupabaseUserSynchronized, isFalse);
      },
    );

    test(
      'switches directly between accounts without logging out to anonymous',
      () async {
        harness.supabaseUserId = _userA;
        harness.listenForAuthChanges();
        harness.configure(initialAppUserId: _userA);
        await harness.settle();

        harness.changeUser(_userB);
        await harness.service.identitySynchronizationTask;

        expect(harness.sdk.loginUserIds, [_userB]);
        expect(harness.sdk.logoutCalls, 0);
        expect(harness.sdk.appUserId, _userB);
        expect(harness.service.isCurrentSupabaseUserSynchronized, isTrue);
      },
    );

    test('latest auth state wins when a login is pending', () async {
      harness.listenForAuthChanges();
      harness.configure();
      await harness.settle();
      final loginGate = Completer<void>();
      harness.sdk.nextLoginGate = loginGate;
      harness.sdk.loginStarted = Completer<void>();

      harness.changeUser(_userA);
      await harness.sdk.loginStarted!.future;
      expect(harness.sdk.loginUserIds, [_userA]);

      harness.changeUser(_userB);
      loginGate.complete();
      await harness.service.identitySynchronizationTask;

      expect(harness.sdk.loginUserIds, [_userA, _userB]);
      expect(harness.sdk.appUserId, _userB);
      expect(harness.service.isCurrentSupabaseUserSynchronized, isTrue);
    });

    test(
      'retries identity failure once and recovers for a new auth state',
      () async {
        harness.listenForAuthChanges();
        harness.configure();
        await harness.settle();
        harness.sdk.loginFailuresRemaining = 2;

        harness.changeUser(_userA);
        await harness.service.identitySynchronizationTask;
        expect(harness.sdk.loginUserIds, [_userA, _userA]);
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.failed,
        );

        harness.changeUser(_userB);
        await harness.service.identitySynchronizationTask;
        expect(harness.sdk.loginUserIds, [_userA, _userA, _userB]);
        expect(harness.sdk.appUserId, _userB);
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.synchronized,
        );
      },
    );

    test(
      'does not attempt logout when RevenueCat initialization is unavailable',
      () async {
        harness.supabaseUserId = _userA;
        harness.sdk.failConfiguration = true;
        harness.listenForAuthChanges();
        harness.configure(initialAppUserId: _userA);
        await harness.settle();

        harness.changeUser(null);
        await harness.service.identitySynchronizationTask;

        expect(harness.sdk.logoutCalls, 0);
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.unavailable,
        );
      },
    );

    test(
      'RevenueCat logout failure does not restore Supabase auth or expose data',
      () async {
        harness.supabaseUserId = _userA;
        harness.listenForAuthChanges();
        harness.configure(initialAppUserId: _userA);
        await harness.settle();
        harness.sdk.logoutFailuresRemaining = 2;

        harness.changeUser(null);
        await harness.service.identitySynchronizationTask;

        expect(harness.supabaseUserId, isNull);
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.failed,
        );
        expect(harness.service.isCurrentSupabaseUserSynchronized, isFalse);
        await expectLater(harness.service.getCustomerInfo(), throwsStateError);

        harness.changeUser(_userB);
        await harness.service.identitySynchronizationTask;
        expect(harness.sdk.appUserId, _userB);
        expect(harness.service.isCurrentSupabaseUserSynchronized, isTrue);
      },
    );

    test(
      'account deletion supersedes a pending login and logs out its identity',
      () async {
        harness.listenForAuthChanges();
        harness.configure();
        await harness.settle();
        final loginGate = Completer<void>();
        harness.sdk.nextLoginGate = loginGate;
        harness.sdk.loginStarted = Completer<void>();

        harness.changeUser(_userA);
        await harness.sdk.loginStarted!.future;
        harness.changeUser(null);
        loginGate.complete();
        await harness.service.identitySynchronizationTask;

        expect(harness.sdk.appUserId, _anonymousId);
        expect(harness.sdk.logoutCalls, 1);
        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.signedOut,
        );
      },
    );

    test('duplicate auth events do not duplicate login requests', () async {
      harness.listenForAuthChanges();
      harness.configure();
      await harness.settle();

      harness.changeUser(_userA);
      harness.authEvents.add(_userA);
      harness.authEvents.add(_userA);
      await harness.service.identitySynchronizationTask;

      expect(harness.sdk.loginUserIds, [_userA]);
    });

    test(
      'does not expose cached customer info while the new user is syncing',
      () async {
        harness.supabaseUserId = _userA;
        harness.listenForAuthChanges();
        harness.configure(initialAppUserId: _userA);
        await harness.settle();
        await harness.service.getCustomerInfo();
        expect(harness.sdk.customerInfoCalls, 1);

        final loginGate = Completer<void>();
        harness.sdk.nextLoginGate = loginGate;
        harness.sdk.loginStarted = Completer<void>();
        harness.changeUser(_userB);
        await harness.sdk.loginStarted!.future;

        await expectLater(harness.service.getCustomerInfo(), throwsStateError);
        expect(harness.sdk.customerInfoCalls, 1);

        loginGate.complete();
        await harness.service.identitySynchronizationTask;
        await harness.service.getCustomerInfo();
        expect(harness.sdk.customerInfoCalls, 2);
      },
    );

    test(
      'stopped auth listener ignores a late identity operation result',
      () async {
        harness.listenForAuthChanges();
        harness.configure();
        await harness.settle();
        final loginGate = Completer<void>();
        harness.sdk.nextLoginGate = loginGate;
        harness.sdk.loginStarted = Completer<void>();

        harness.changeUser(_userA);
        await harness.sdk.loginStarted!.future;
        final operation = harness.service.identitySynchronizationTask;
        await harness.service.stopIdentitySynchronization();
        loginGate.complete();
        await operation;

        expect(
          harness.service.identityState.value.status,
          RevenueCatIdentityStatus.stopped,
        );
        expect(harness.service.isCurrentSupabaseUserSynchronized, isFalse);
      },
    );
  });
}
