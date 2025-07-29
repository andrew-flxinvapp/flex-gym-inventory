import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/supabase_service.dart';

/// 1. Auth Service Provider
final authServiceProvider = Provider<SupabaseAuthService>((ref) => SupabaseAuthService());

/// 2. Auth State Provider (stream of current user)
final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// 4. Magic Link State Provider (simple state for magic link sent status)
final magicLinkSentProvider = StateProvider<bool>((ref) => false);

/// 5. Biometric Auth Provider (simple state for biometric auth result)
final biometricAuthProvider = StateProvider<bool>((ref) => false);
