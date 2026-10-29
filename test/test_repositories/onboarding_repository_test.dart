import 'dart:convert';

import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/data/repositories/onboarding_repository.dart';
import 'package:flex_gym_inventory/src/screens/startup_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userId = 'c0a80123-4567-489a-bcde-123456789abc';
const _userEmail = 'newuser@example.com';

String _accessToken() {
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({
            'sub': _userId,
            'exp':
                DateTime.now()
                    .add(const Duration(hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          }),
        ),
      )
      .replaceAll('=', '');
  return 'eyJhbGciOiJub25lIn0.$payload.';
}

Future<SupabaseClient> _authenticatedClient(
  Future<http.Response> Function(http.Request request) handler,
) async {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'test-anon-key',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
    httpClient: MockClient(handler),
  );
  await client.auth.recoverSession(
    jsonEncode({
      'access_token': _accessToken(),
      'expires_in': 3600,
      'refresh_token': 'test-refresh-token',
      'token_type': 'bearer',
      'user': {
        'id': _userId,
        'email': _userEmail,
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
      },
    }),
  );
  return client;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'upserts names and onboarding data for the authenticated user',
    () async {
      http.Request? upsertRequest;
      final client = await _authenticatedClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('/profiles')) {
          upsertRequest = request;
          return http.Response('', 201, request: request);
        }
        return http.Response('[]', 200, request: request);
      });

      await OnboardingRepository(client: client).completeOnboarding(
        firstName: 'Alex',
        lastName: 'Smith',
        notificationsOn: true,
      );

      expect(upsertRequest, isNotNull);
      final row = jsonDecode(upsertRequest!.body) as Map<String, dynamic>;
      expect(row['id'], _userId);
      expect(row['first_name'], 'Alex');
      expect(row['last_name'], 'Smith');
      expect(row['notifications_on'], isTrue);
      expect(
        DateTime.tryParse(row['onboarding_completed_at'] as String),
        isNotNull,
      );
      expect(row['first_name'], isNotEmpty);
      expect(row['last_name'], isNotEmpty);

      await client.dispose();
    },
  );

  test(
    'failed profile upsert propagates and leaves onboarding incomplete',
    () async {
      final client = await _authenticatedClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('/profiles')) {
          return http.Response(
            jsonEncode({'code': 'write_failed', 'message': 'write failed'}),
            500,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }
        return http.Response('[]', 200, request: request);
      });
      final repository = OnboardingRepository(client: client);

      await expectLater(
        repository.completeOnboarding(
          firstName: 'Alex',
          lastName: 'Smith',
          notificationsOn: false,
        ),
        throwsA(isA<PostgrestException>()),
      );
      expect(await repository.fetchOnboardingCompleteFromProfile(), isFalse);

      await client.dispose();
    },
  );

  test(
    'omits empty names instead of overwriting existing profile values',
    () async {
      http.Request? upsertRequest;
      final client = await _authenticatedClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('/profiles')) {
          upsertRequest = request;
          return http.Response('', 201, request: request);
        }
        return http.Response('[]', 200, request: request);
      });

      await OnboardingRepository(client: client).completeOnboarding(
        firstName: '',
        lastName: '  ',
        notificationsOn: false,
      );

      final row = jsonDecode(upsertRequest!.body) as Map<String, dynamic>;
      expect(row.containsKey('first_name'), isFalse);
      expect(row.containsKey('last_name'), isFalse);
      expect(row['notifications_on'], isFalse);
      expect(row['onboarding_completed_at'], isNotNull);

      await client.dispose();
    },
  );

  test('successful completion routes a later login to the dashboard', () async {
    var onboardingCompletedAt = '2026-10-29T20:00:00Z';
    final client = await _authenticatedClient((request) async {
      if (request.method == 'POST' && request.url.path.endsWith('/profiles')) {
        final row = jsonDecode(request.body) as Map<String, dynamic>;
        onboardingCompletedAt = row['onboarding_completed_at'] as String;
        return http.Response('', 201, request: request);
      }
      if (request.method == 'GET' && request.url.path.endsWith('/profiles')) {
        return http.Response(
          jsonEncode([
            {'onboarding_completed_at': onboardingCompletedAt},
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }
      return http.Response('[]', 200, request: request);
    });
    final repository = OnboardingRepository(client: client);

    await repository.completeOnboarding(
      firstName: 'Alex',
      lastName: 'Smith',
      notificationsOn: false,
    );

    final subsequentLogin = await _authenticatedClient((request) async {
      if (request.method == 'GET' && request.url.path.endsWith('/profiles')) {
        return http.Response(
          jsonEncode([
            {'onboarding_completed_at': onboardingCompletedAt},
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }
      return http.Response('[]', 200, request: request);
    });

    expect(
      await resolveStartupRoute(
        onboardingRepository: OnboardingRepository(client: subsequentLogin),
        testSession: subsequentLogin.auth.currentSession,
      ),
      AppRoutes.dashboard,
    );

    await subsequentLogin.dispose();
    await client.dispose();
  });
}
