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
    required bool notificationsOn,
    String? firstName,
    String? lastName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user for onboarding');

    // Resolve names: prefer explicit params, then pending store, then auth metadata.
    String? resolvedFirst = firstName;
    String? resolvedLast = lastName;

    // If caller did not provide names, fall back to auth user metadata.

    final meta = user.userMetadata ?? <String, dynamic>{};
    if (resolvedFirst == null && meta.containsKey('first_name')) {
      final v = meta['first_name'];
      if (v is String && v.trim().isNotEmpty) resolvedFirst = v;
    }
    if (resolvedLast == null && meta.containsKey('last_name')) {
      final v = meta['last_name'];
      if (v is String && v.trim().isNotEmpty) resolvedLast = v;
    }

    final row = <String, dynamic>{
      'id': user.id,
      'notifications_on': notificationsOn,
      'onboarding_completed_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (resolvedFirst != null && resolvedFirst.trim().isNotEmpty) {
      row['first_name'] = resolvedFirst.trim();
    }
    if (resolvedLast != null && resolvedLast.trim().isNotEmpty) {
      row['last_name'] = resolvedLast.trim();
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

