import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';

class AuthCallbackHandler {
  AuthCallbackHandler({
    required this.verifyToken,
    required this.onAuthenticationError,
    required this.onOtherLink,
  });

  final Future<void> Function(String tokenHash, OtpType type) verifyToken;
  final void Function() onAuthenticationError;
  final Future<void> Function(Map<String, String> params) onOtherLink;
  final Set<String> _verifyingTokens = {};
  final Set<String> _verifiedTokens = {};

  Future<void> handle(Uri uri, Map<String, String> params) async {
    LogHandler.info('Deeplink', 'Deeplink received');

    // These are handled by supabase_flutter's automatic URI observer.
    if ([
      'code',
      'access_token',
      'error',
      'error_code',
      'error_description',
    ].any(params.containsKey)) {
      return;
    }

    final tokenHash = params['token_hash'];
    if (tokenHash != null) {
      if (tokenHash.isEmpty) {
        onAuthenticationError();
        return;
      }
      if (_verifiedTokens.contains(tokenHash) ||
          !_verifyingTokens.add(tokenHash)) {
        return;
      }
      try {
        final type = switch (params['type']) {
          'signup' => OtpType.signup,
          'invite' => OtpType.invite,
          'recovery' => OtpType.recovery,
          'email_change' => OtpType.emailChange,
          'email' => OtpType.email,
          _ => OtpType.magiclink,
        };
        await verifyToken(tokenHash, type);
        _verifiedTokens.add(tokenHash);
        LogHandler.info('Deeplink', 'Token-hash verification completed');
      } catch (_) {
        onAuthenticationError();
      } finally {
        _verifyingTokens.remove(tokenHash);
      }
      return;
    }

    if (params.containsKey('refresh_token')) {
      onAuthenticationError();
      return;
    }
    await onOtherLink(params);
  }
}
