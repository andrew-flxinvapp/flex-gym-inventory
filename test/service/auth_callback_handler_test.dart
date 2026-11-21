import 'dart:async';

import 'package:flex_gym_inventory/service/auth_callback_handler.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'SDK-managed callbacks do not invoke manual verification or navigation',
    () async {
      var verifications = 0;
      var otherLinks = 0;
      var errors = 0;
      final handler = AuthCallbackHandler(
        verifyToken: (_, _) async => verifications++,
        onAuthenticationError: () => errors++,
        onOtherLink: (_) async => otherLinks++,
      );

      for (final params in [
        {'code': 'code'},
        {'access_token': 'access', 'refresh_token': 'refresh'},
        {'error': 'access_denied'},
        {'code': 'code', 'token_hash': 'hash'},
      ]) {
        await handler.handle(
          Uri.parse('flexgyminventory://auth-callback'),
          params,
        );
      }

      expect(verifications, 0);
      expect(otherLinks, 0);
      expect(errors, 0);
    },
  );

  test(
    'token hash is verified once during and after duplicate delivery',
    () async {
      final verification = Completer<void>();
      final calls = <(String, OtpType)>[];
      var errors = 0;
      final handler = AuthCallbackHandler(
        verifyToken: (hash, type) {
          calls.add((hash, type));
          return verification.future;
        },
        onAuthenticationError: () => errors++,
        onOtherLink: (_) async => fail('Unexpected other link'),
      );
      final uri = Uri.parse('flexgyminventory://auth-callback');
      final params = {'token_hash': 'hash', 'type': 'signup'};

      final first = handler.handle(uri, params);
      await handler.handle(uri, params);
      expect(calls, [('hash', OtpType.signup)]);
      verification.complete();
      await first;
      await handler.handle(uri, params);
      expect(calls, hasLength(1));
      expect(errors, 0);
    },
  );

  test(
    'failed token verification reports an error and permits retry',
    () async {
      var calls = 0;
      var errors = 0;
      final handler = AuthCallbackHandler(
        verifyToken: (_, type) async {
          expect(type, OtpType.magiclink);
          if (++calls == 1) throw Exception('failure');
        },
        onAuthenticationError: () => errors++,
        onOtherLink: (_) async => fail('Unexpected other link'),
      );
      final uri = Uri.parse('flexgyminventory://auth-callback');
      final params = {'token_hash': 'hash'};
      await handler.handle(uri, params);
      await handler.handle(uri, params);
      expect(calls, 2);
      expect(errors, 1);
    },
  );

  test(
    'other links retain their parameters and malformed auth is reported',
    () async {
      Map<String, String>? forwarded;
      var errors = 0;
      final handler = AuthCallbackHandler(
        verifyToken: (_, _) async => fail('Unexpected verification'),
        onAuthenticationError: () => errors++,
        onOtherLink: (params) async => forwarded = params,
      );
      final uri = Uri.parse('flexgyminventory://auth-callback');
      await handler.handle(uri, {'email': 'user@example.com'});
      await handler.handle(uri, {'token_hash': ''});
      await handler.handle(uri, {'refresh_token': 'refresh'});
      expect(forwarded, {'email': 'user@example.com'});
      expect(errors, 2);
    },
  );

  test('callback diagnostics do not expose credentials', () async {
    LogHandler.setupLogging();
    final records = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(records.add);
    final handler = AuthCallbackHandler(
      verifyToken: (_, _) async => throw Exception('secret-hash'),
      onAuthenticationError: () => LogHandler.warning('Auth', 'Failed'),
      onOtherLink: (_) async => fail('Unexpected other link'),
    );
    await handler.handle(
      Uri.parse('flexgyminventory://auth-callback?code=secret-code'),
      {'code': 'secret-code'},
    );
    await handler.handle(
      Uri.parse('flexgyminventory://auth-callback?token_hash=secret-hash'),
      {'token_hash': 'secret-hash'},
    );
    final output = records
        .map((record) => '${record.message} ${record.error ?? ''}')
        .join('\n');
    expect(output, isNot(contains('secret-code')));
    expect(output, isNot(contains('secret-hash')));
    expect(
      Logger('supabase.supabase_flutter').isLoggable(Level.FINEST),
      isFalse,
    );
    await subscription.cancel();
  });
}
