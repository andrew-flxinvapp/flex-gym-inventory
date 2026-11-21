import 'dart:async';
import 'dart:convert';

import 'package:flex_gym_inventory/service/auth_callback_handler.dart';
import 'package:flex_gym_inventory/service/deeplink_service.dart';
import 'package:flex_gym_inventory/service/revenuecat_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryStorage extends GotrueAsyncStorage {
  final values = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => values[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final coldStart in [true, false]) {
    test(
      '${coldStart ? 'Cold-start' : 'Resumed'} callback is exchanged only by the SDK',
      () async {
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const messages = MethodChannel('com.llfbandit.app_links/messages');
        const events = MethodChannel('com.llfbandit.app_links/events');
        const callback = 'flexgyminventory://auth-callback?code=test-code';
        Future<void> deliver() => messenger.handlePlatformMessage(
          events.name,
          const StandardMethodCodec().encodeSuccessEnvelope(callback),
          (_) {},
        );
        messenger.setMockMethodCallHandler(
          messages,
          (call) async =>
              coldStart && call.method == 'getInitialLink' ? callback : null,
        );
        messenger.setMockMethodCallHandler(events, (call) async {
          if (coldStart && call.method == 'listen') {
            unawaited(deliver());
          }
          return null;
        });

        final storage = _MemoryStorage();
        await storage.setItem(
          key: 'supabase.auth.token-code-verifier',
          value: 'test-verifier',
        );
        var exchanges = 0;
        final client = MockClient((request) async {
          expect(request.url.path, endsWith('/token'));
          expect(request.url.queryParameters['grant_type'], 'pkce');
          expect(jsonDecode(request.body)['auth_code'], 'test-code');
          exchanges++;
          return http.Response(
            jsonEncode({
              'access_token': 'test-token',
              'refresh_token': 'test-refresh',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': {'id': 'user', 'aud': 'authenticated', 'created_at': ''},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        await Supabase.initialize(
          url: 'https://example.supabase.co',
          publishableKey: 'test-key',
          httpClient: client,
          authOptions: FlutterAuthClientOptions(
            persistSession: false,
            autoRefreshToken: false,
            pkceAsyncStorage: storage,
          ),
        );
        var revenueCatUserId = r'$RCAnonymousID:test';
        final synchronized = Completer<void>();
        final revenueCat = RevenueCatService(
          configureSdk: ({required apiKey, appUserId}) async {},
          currentAppUserIdReader: () async => revenueCatUserId,
          identityLogIn: (userId) async {
            revenueCatUserId = userId;
            return null;
          },
          identityLogOut: () async {
            revenueCatUserId = r'$RCAnonymousID:test';
          },
          customerInfoReader: () async => null,
        );
        revenueCat.identityState.addListener(() {
          if (revenueCat.identityState.value.status ==
                  RevenueCatIdentityStatus.synchronized &&
              !synchronized.isCompleted) {
            synchronized.complete();
          }
        });
        final auth = Supabase.instance.client.auth;
        revenueCat.startIdentitySynchronization(
          authUserIds: auth.onAuthStateChange.map(
            (event) => event.session?.user.id,
          ),
          currentUserId: () => auth.currentUser?.id,
        );
        revenueCat.startConfiguration(apiKey: 'test-key');
        await revenueCat.initializationTask;
        final signedIn = Supabase.instance.client.auth.onAuthStateChange
            .firstWhere((event) => event.event == AuthChangeEvent.signedIn);
        final appReceived = Completer<void>();
        final handler = AuthCallbackHandler(
          verifyToken: (_, _) async => fail('Unexpected token verification'),
          onAuthenticationError: () => fail('Unexpected callback failure'),
          onOtherLink: (_) async => fail('Unexpected other link'),
        );
        DeeplinkService.instance.registerHandler((uri, params) async {
          await handler.handle(uri, params);
          if (!appReceived.isCompleted) appReceived.complete();
        });
        await DeeplinkService.instance.init();

        if (!coldStart) await deliver();
        await Future.wait([
          signedIn.timeout(const Duration(seconds: 5)),
          appReceived.future.timeout(const Duration(seconds: 5)),
          synchronized.future.timeout(const Duration(seconds: 5)),
        ]);

        expect(exchanges, 1);
        expect(Supabase.instance.client.auth.currentUser?.id, 'user');
        expect(revenueCatUserId, 'user');

        await revenueCat.stopIdentitySynchronization();
        await DeeplinkService.instance.dispose();
        await Supabase.instance.dispose();
        client.close();
        messenger.setMockMethodCallHandler(messages, null);
        messenger.setMockMethodCallHandler(events, null);
      },
    );
  }
}
