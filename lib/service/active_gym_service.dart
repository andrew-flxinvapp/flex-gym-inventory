import 'package:isar/isar.dart';
import '../src/models/app_state_model.dart';
import '../src/models/gym_model.dart';

/// Manages the user's active/defualt gym.
/// Stores a single AppState row (id=1)
/// Scopes the rest of the app (lists, filters, exports) to the active gym.
class ActiveGymService {
  ActiveGymService(this.isar);
  final Isar isar;

  /// Returns the active gymId. If non is set or it's invalid.
  /// Falls back to the first gym and persists it.
  Future<String> getActiveGymId() async {
    final state = await isar.appStates.get(1);
    final saved = state?.activeGymId;

    if (saved != null && saved.isNotEmpty) {
      // Ensure it still exists (gym could have been deleted)
      final exists = await isar.gyms.where().gymIdEqualTo(saved).findFirst();
      if (exists != null) return saved;
    }

    // Fallback: pick first gym 
    final firstGym = await isar.gyms.where().anyId().findFirst();
    if (firstGym == null) {
      throw StateError('No gyms exist yet. Create a gym first.');
    }

    await setActiveGymId(firstGym.gymId);
    return firstGym.gymId;
  }

  /// Returns the full active Gym object (null if none available)
  Future<Gym?> getActiveGym() async {
    try {
      final id = await getActiveGymId();
      return isar.gyms.where().gymIdEqualTo(id).findFirst();
    } catch (_) {
      return null;
    }
  }

  /// Persist a new active/default gymId
  Future<void> setActiveGymId(String gymId) async {
    await isar.writeTxn(() async {
      final state = (await isar.appStates.get(1)) ?? AppState();
      state.activeGymId = gymId;
      await isar.appStates.put(state);
    });
  }

  /// Clears the active gym (next read will fallback to first gym)
  Future<void> clearActiveGym() async {
    await isar.writeTxn(() async {
      final state = (await isar.appStates.get(1)) ?? AppState();
      state.activeGymId = null;
      await isar.appStates.put(state);
    });
  }

  /// Emits the current active gymId and any future changes.
  /// Use this to refresh screens when user switches default gym.
  Stream<String?> watchActiveGymId() {
    return isar.appStates
        .watchObject(1, fireImmediately: true)
        .map((s) => s?.activeGymId);
  }

  /// If the active gym was deleted, reset to the first remaining gym (if any).
  /// Returns true if it fixed an invalid state.
  Future<bool> repairIfMissing() async {
    final state = await isar.appStates.get(1);
    final id = state?.activeGymId;
    if (id == null || id.isEmpty) return false;

    final exists = await isar.gyms.where().gymIdEqualTo(id).findFirst();
    if (exists != null) return false;

    final firstGym = await isar.gyms.where().anyId().findFirst();
    if (firstGym == null) {
      await clearActiveGym();
      return true;
    }
    await setActiveGymId(firstGym.gymId);
    return true;
  }
}