// lib/src/repositories/user_local_repository.dart

import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/user_prefs_model.dart';

/// Local repository for user-scoped data persisted in Isar.
///
/// This keeps Isar usage contained and provides a small API the app can use
/// (and the `AuthRepository` can call) to reconcile Supabase users into local
/// storage.
class UserLocalRepository {
  /// Get preferences for a given Supabase user id.
  Future<UserPrefs?> getPrefsByUserId(String userId) async {
  final isar = IsarService.isar;
  return isar.userPrefs.where().userIdEqualTo(userId).findFirst();
  }

  /// Insert or replace the given [prefs].
  Future<void> upsertPrefs(UserPrefs prefs) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.userPrefs.put(prefs);
    });
  }

  /// Ensure a prefs row exists for [userId] and return it. This is useful
  /// when reconciling a remote auth user into local state.
  Future<UserPrefs> ensurePrefsForUser(String userId) async {
    var prefs = await getPrefsByUserId(userId);
    if (prefs != null) return prefs;
    prefs = UserPrefs()
      ..userId = userId
      ..defaultGymId = null;
    await upsertPrefs(prefs);
    return prefs;
  }

  /// Convenience helper to create/update prefs from a Supabase user map.
  /// The map is expected to contain either `id` or `user_id` as the user id.
  Future<UserPrefs> upsertFromSupabaseUserMap(Map<String, dynamic> map) async {
    final userId = (map['id'] ?? map['user_id']) as String?;
    if (userId == null) {
      throw ArgumentError('Supabase user map does not contain an id');
    }

    final existing = await getPrefsByUserId(userId);
    if (existing != null) {
      // No user-prefs fields in Supabase by default; just return existing.
      return existing;
    }

    final prefs = UserPrefs()
      ..userId = userId
      ..defaultGymId = null;
    await upsertPrefs(prefs);
    return prefs;
  }
}
