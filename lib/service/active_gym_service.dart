import 'package:isar/isar.dart';
import '../src/models/app_state_model.dart';
import '../src/models/gym_model.dart';
import 'ownership_context.dart';

/// Manages the user's active/defualt gym.
/// Stores a single AppState row (id=1)
/// Scopes the rest of the app (lists, filters, exports) to the active gym.
class ActiveGymService {
  ActiveGymService(this.isar, {OwnershipContext? ownershipContext})
    : _ownershipContext = ownershipContext ?? OwnershipContext();

  final Isar isar;
  final OwnershipContext _ownershipContext;

  /// Returns the current user's active gym ID, falling back to their first gym.
  Future<String> getActiveGymId() async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) {
      throw StateError('An authenticated user is required to select a gym.');
    }

    final state = await isar.appStates.get(1);
    final saved = state?.activeGymId;

    if (saved != null && saved.isNotEmpty) {
      final owned =
          await isar.gyms
              .filter()
              .userIdEqualTo(userId)
              .and()
              .gymIdEqualTo(saved)
              .findFirst();
      if (owned != null && _ownershipContext.isCurrentUser(userId)) {
        return saved;
      }
    }

    final firstGym = await isar.gyms.filter().userIdEqualTo(userId).findFirst();
    if (firstGym == null) {
      throw StateError('No gyms exist for the current user.');
    }

    if (!await setActiveGymId(firstGym.gymId)) {
      throw StateError('Unable to select a gym for the current user.');
    }
    return firstGym.gymId;
  }

  /// Returns the full active Gym object (null if none available)
  Future<Gym?> getActiveGym() async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;

    late final String id;
    try {
      id = await getActiveGymId();
    } on StateError {
      return null;
    }
    final gym =
        await isar.gyms
            .filter()
            .userIdEqualTo(userId)
            .and()
            .gymIdEqualTo(id)
            .findFirst();
    if (!_ownershipContext.isCurrentUser(userId)) return null;
    return gym;
  }

  /// Persist a new active/default gymId only when it belongs to this user.
  Future<bool> setActiveGymId(String gymId) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return false;

    return isar.writeTxn(() async {
      final gym =
          await isar.gyms
              .filter()
              .userIdEqualTo(userId)
              .and()
              .gymIdEqualTo(gymId)
              .findFirst();
      if (gym == null || !_ownershipContext.isCurrentUser(userId)) {
        return false;
      }

      final state = (await isar.appStates.get(1)) ?? AppState();
      state.activeGymId = gymId;
      await isar.appStates.put(state);
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while selecting a gym.');
      }
      return true;
    });
  }

  /// Clears the app-wide active selection without deleting any gym data.
  Future<void> clearActiveGym() async {
    await isar.writeTxn(() async {
      final state = (await isar.appStates.get(1)) ?? AppState();
      state.activeGymId = null;
      await isar.appStates.put(state);
    });
  }

  /// Emits the active gym ID only when it belongs to the authenticated user.
  Stream<String?> watchActiveGymId() {
    return isar.appStates.watchObject(1, fireImmediately: true).asyncMap((
      state,
    ) async {
      final userId = _ownershipContext.currentUserId;
      final id = state?.activeGymId;
      if (userId == null || id == null || id.isEmpty) return null;

      final gym =
          await isar.gyms
              .filter()
              .userIdEqualTo(userId)
              .and()
              .gymIdEqualTo(id)
              .findFirst();
      return _ownershipContext.isCurrentUser(userId) ? gym?.gymId : null;
    });
  }

  /// If the active gym is invalid for this user, select only one of their gyms.
  Future<bool> repairIfMissing() async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return false;

    final state = await isar.appStates.get(1);
    final id = state?.activeGymId;
    if (id == null || id.isEmpty) return false;

    final owned =
        await isar.gyms
            .filter()
            .userIdEqualTo(userId)
            .and()
            .gymIdEqualTo(id)
            .findFirst();
    if (owned != null) return false;

    final firstGym = await isar.gyms.filter().userIdEqualTo(userId).findFirst();
    if (!_ownershipContext.isCurrentUser(userId)) return false;
    if (firstGym == null) return false;
    return setActiveGymId(firstGym.gymId);
  }
}
