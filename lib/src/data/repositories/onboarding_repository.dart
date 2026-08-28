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
  Future<void> completeOnboarding({required bool notificationsOn}) async {
    await _client.auth.updateUser(
      UserAttributes(
        data: {'onboardingComplete': true, 'notificationsOn': notificationsOn},
      ),
    );
  }

  /// Update only the `notificationsOn` flag in user metadata.
  ///
  /// This is a lightweight call that can be used earlier in onboarding
  /// (for example immediately after the system permission request) so
  /// that Settings reflects the user's current choice.
  Future<void> updateNotificationsOn(bool enabled) async {
    await _client.auth.updateUser(
      UserAttributes(
        data: {'notificationsOn': enabled},
      ),
    );
  }

  /// (Optional) Convenience getter — reads metadata for current user.
  Map<String, dynamic> get metadata {
    final user = _client.auth.currentUser;
    return user?.userMetadata ?? <String, dynamic>{};
  }

  /// (Optional) Typed convenience flags.
  bool get isOnboardingComplete => metadata['onboardingComplete'] == true;

  bool get notificationsEnabled => metadata['notificationsOn'] == true;

  bool get hasProPlan => metadata['proPlan'] == true;

  /// Fetch the `notificationsOn` flag from the current user's metadata.
  /// Returns `null` if there is no authenticated user or no value set.
  Future<bool?> fetchNotificationsOn() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final meta = user.userMetadata ?? <String, dynamic>{};
    if (meta.containsKey('notificationsOn')) {
      return meta['notificationsOn'] == true;
    }
    return null;
  }
}

