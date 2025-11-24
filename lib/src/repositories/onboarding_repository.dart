// lib/src/repositories/onboarding_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles all onboarding-related updates to Supabase user_metadata.
///
/// Fields written:
/// - onboardingComplete : bool
/// - notificationsOn    : bool
/// - proPlan            : bool
///
/// This repository does NOT handle routing or UI state.
/// It simply updates the authenticated user's metadata in Supabase.
class OnboardingRepository {
  final SupabaseClient _client;

  /// Allows optional injection of a mock/fake client during testing.
  OnboardingRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Called at the final step of the onboarding flow.
  ///
  /// Writes user metadata in a single atomic update:
  /// {
  ///   "onboardingComplete": true,
  ///   "notificationsOn": notificationsOn,
  ///   "proPlan": proPlan
  /// }
  Future<void> completeOnboarding({
    required bool notificationsOn,
    required bool proPlan,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          'onboardingComplete': true,
          'notificationsOn': notificationsOn,
          'proPlan': proPlan,
        },
      ),
    );
  }

  /// (Optional) Convenience getter — reads metadata for current user.
  Map<String, dynamic> get metadata {
    final user = _client.auth.currentUser;
    return user?.userMetadata ?? <String, dynamic>{};
  }

  /// (Optional) Typed convenience flags.
  bool get isOnboardingComplete =>
      metadata['onboardingComplete'] == true;

  bool get notificationsEnabled =>
      metadata['notificationsOn'] == true;

  bool get hasProPlan =>
      metadata['proPlan'] == true;
}
