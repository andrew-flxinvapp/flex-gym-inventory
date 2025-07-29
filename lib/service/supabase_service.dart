import 'package:supabase_flutter/supabase_flutter.dart';

/// A service class for handling Supabase authentication, magic link, and biometrics.
class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;


  /// Send a magic link (OTP) to the user's email for passwordless sign up or sign in
  Future<void> sendMagicLink({required String email}) async {
    await _client.auth.signInWithOtp(email: email);
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get the current user
  User? get currentUser => _client.auth.currentUser;

  /// Example: Biometric authentication placeholder
  /// Implement platform-specific biometric logic as needed
  Future<bool> authenticateWithBiometrics() async {
    // Integrate with local_auth or similar package for biometrics
    // Return true if successful, false otherwise
    return false;
  }
}
