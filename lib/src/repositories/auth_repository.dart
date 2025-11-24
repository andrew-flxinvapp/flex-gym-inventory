// lib/src/repositories/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Encapsulates authentication flows against Supabase and provides a
/// small, testable surface for the app to call.
///
/// Responsibilities:
/// - signInWithMagicLink
/// - signUp
/// - resendMagicLink
/// - signOut
/// - currentUser
/// - map Supabase errors to a small [AuthException]
/// - optionally reconcile the Supabase user with local storage via
///   an injected `localUserUpsert` callback (useful for Isar integration)
class AuthRepository {
  final SupabaseClient _client;

  /// Optional callback that receives a plain map of the Supabase user and
  /// should persist / reconcile it into local storage (e.g., Isar). This
  /// keeps this repository free of concrete Isar types while still allowing
  /// the app to hook in reconciliation logic.
  final Future<void> Function(Map<String, dynamic> user)? localUserUpsert;

  AuthRepository({SupabaseClient? client, this.localUserUpsert})
      : _client = client ?? Supabase.instance.client;

  /// Send a magic link sign-in email to [email].
  Future<void> signInWithMagicLink(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);
    } catch (e, st) {
      throw _mapToAuthException(e, st);
    }
  }

  /// Create an account for [email]. Depending on your Supabase settings this
  /// may send a confirmation email or sign the user in immediately.
  Future<void> signUp(String email, {String? password}) async {
    try {
      // supabase API accepts an optional password. If your app uses magic
      // links only, password can be null and the backend may still accept it.
      if (password == null) {
        // If no password is supplied, request a magic link which will
        // behave like a sign-up flow if the user doesn't exist yet.
        await _client.auth.signInWithOtp(email: email);
      } else {
        await _client.auth.signUp(email: email, password: password);
      }
    } catch (e, st) {
      throw _mapToAuthException(e, st);
    }
  }

  /// Resend a magic link. This is implemented by calling the same API used
  /// to request a magic link again.
  Future<void> resendMagicLink(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);
    } catch (e, st) {
      throw _mapToAuthException(e, st);
    }
  }

  /// Sign the current user out.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, st) {
      throw _mapToAuthException(e, st);
    }
  }

  /// Returns the currently authenticated Supabase user, or `null`.
  User? get currentUser => _client.auth.currentUser;

  /// Convenience: call this after a successful sign-in / sign-up to persist
  /// the user locally. The repository itself doesn't assume any local DB
  /// implementation — instead the optional [localUserUpsert] callback is
  /// invoked if provided.
  Future<void> reconcileLocalUser() async {
    final user = currentUser;
    if (user == null) return;
    if (localUserUpsert == null) return;

    final map = <String, dynamic>{
      'id': user.id,
      'email': user.email,
      'phone': user.phone,
      'app_metadata': user.appMetadata,
      'user_metadata': user.userMetadata,
      // Supabase's createdAt is a String timestamp in many versions.
      'created_at': user.createdAt,
    };

    await localUserUpsert!(map);
  }

  /// Map low-level exceptions to a small AuthException domain type.
  AuthException _mapToAuthException(Object e, StackTrace st) {
    // supabase packages may throw objects with a `message` property. We
    // conservatively convert known shapes to friendly errors and fall back
    // to a generic unknown error.
    String? message;
    try {
      if (e is AuthException) {
        // If Supabase's package defines an AuthException, reuse its message.
        message = e.message;
      } else if (e is PostgrestException) {
        message = e.message;
      } else if (e is Exception) {
        message = e.toString();
      } else {
        message = '$e';
      }
    } catch (_) {
      message = 'An unknown auth error occurred.';
    }

    // Very small mapping: common cases have obvious text; otherwise unknown.
    if (message != null && message.toLowerCase().contains('invalid')) {
      return AuthException(AuthError.invalidCredentials, message);
    }
    if (message != null && message.toLowerCase().contains('not found')) {
      return AuthException(AuthError.notFound, message);
    }
    if (message != null && message.toLowerCase().contains('network')) {
      return AuthException(AuthError.network, message);
    }

    return AuthException(AuthError.unknown, message ?? 'Unknown error');
  }
}

/// Small domain-level auth errors.
enum AuthError { invalidCredentials, notFound, network, unknown }

class AuthException implements Exception {
  final AuthError error;
  final String? message;

  AuthException(this.error, [this.message]);

  @override
  String toString() => 'AuthException($error): ${message ?? ''}';
}
