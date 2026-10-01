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
  /// Performs an authenticated upsert into `public.profiles` so the DB row
  /// becomes the canonical source of profile/onboarding data. This method
  /// is intentionally conservative in this pass:
  /// - It writes to `public.profiles` using snake_case column names.
  /// - For compatibility it will set `auth.user_metadata.onboardingComplete`
  ///   only after the profile upsert succeeds.
  ///
  /// Parameters:
  /// - `notificationsOn` (required): whether notifications are enabled.
  /// - `firstName`/`lastName` (optional): prefer caller-provided names;
  ///   otherwise pending metadata and user metadata are consulted.
  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required bool notificationsOn,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user for onboarding');

    // Use only the explicit names provided by the caller.

    final row = <String, dynamic>{
      'id': user.id,
      'notifications_on': notificationsOn,
      'onboarding_completed_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (firstName.trim().isNotEmpty) {
      row['first_name'] = firstName.trim();
    }
    if (lastName.trim().isNotEmpty) {
      row['last_name'] = lastName.trim();
    }

    // Upsert the profile row. Let errors bubble up so callers can react.
    await _client.from('profiles').upsert(row);
  }

  /// Update only the `notificationsOn` flag in user metadata.
  ///
  /// This is a lightweight call that can be used earlier in onboarding
  /// (for example immediately after the system permission request) so
  /// that Settings reflects the user's current choice.
  Future<void> updateNotificationsOn(bool enabled) async {
    // Persist notifications preference to the canonical `profiles` row
    // instead of writing it to `auth.user_metadata`.
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user for updating notifications');

    final row = <String, dynamic>{
      'id': user.id,
      'notifications_on': enabled,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    await _client.from('profiles').upsert(row);
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
  /// Fetch the `notifications_on` flag from the canonical `public.profiles`
  /// row for the current user. Returns `null` if there is no authenticated
  /// user or no value set.
  Future<bool?> fetchNotificationsOn() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final row = await _client
          .from('profiles')
          .select('notifications_on')
          .eq('id', user.id)
          .maybeSingle();

      if (row == null) return null;
      if (row.containsKey('notifications_on')) {
        return row['notifications_on'] == true;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch whether onboarding is complete by reading the canonical
  /// `public.profiles.onboarding_completed_at` column for the current user.
  /// Returns `true` when a non-null timestamp is present, `false` otherwise.
  /// Any errors are caught and `false` is returned so callers fall back to
  /// onboarding flow instead of blocking the user.
  Future<bool> fetchOnboardingCompleteFromProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final row = await _client
          .from('profiles')
          .select('onboarding_completed_at')
          .eq('id', user.id)
          .maybeSingle();

      if (row == null) return false;
      if (row['onboarding_completed_at'] != null) return true;
      return false;
    } catch (_) {
      // Swallow errors and treat as not complete so routing sends the user
      // into onboarding. Calling code may surface logs / telemetry.
      return false;
    }
  }
}

