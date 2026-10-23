import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/service/ownership_context.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';

/// Sort modes that map to your fields.
enum GymSort { nameAsc, nameDesc, newest, oldest }

class GymRepository {
  GymRepository({Isar? isar, OwnershipContext? ownershipContext})
    : _isar = isar,
      _ownershipContext = ownershipContext ?? OwnershipContext();

  final Isar? _isar;
  final OwnershipContext _ownershipContext;

  Isar get _database => _isar ?? IsarService.isar;

  // -------------------- Create / Update / Delete -----------------------------

  /// Create a new gym and insert it.
  Future<Gym> createGym({
    required String gymId,
    required String name,
    required String userId,
    String? location,
    String? gymNotes,
  }) async {
    final currentUserId = _ownershipContext.currentUserId;
    if (currentUserId == null || currentUserId != userId) {
      throw StateError('An authenticated owner is required to create a gym.');
    }

    final gym = Gym(
      gymId: gymId,
      name: name,
      userId: userId,
      location: location,
      gymNotes: gymNotes,
      createdDate: DateTime.now(),
    );
    if (!_ownershipContext.isCurrentUser(currentUserId)) {
      throw StateError('Authentication changed while creating the gym.');
    }
    await upsert(gym);
    return gym;
  }

  /// Update an existing gym by Isar id.
  Future<Gym?> updateGym({
    required int id,
    String? name,
    String? location,
    String? gymNotes,
  }) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;

    return _database.writeTxn(() async {
      final gym = await _database.gyms.get(id);
      if (gym == null ||
          gym.userId != userId ||
          !_ownershipContext.isCurrentUser(userId)) {
        return null;
      }
      if (name != null) gym.name = name;
      if (location != null) gym.location = location;
      if (gymNotes != null) gym.gymNotes = gymNotes;
      await _database.gyms.put(gym);
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while updating the gym.');
      }
      return gym;
    });
  }

  /// Delete a gym by Isar id and return the deleted gym.
  Future<Gym?> deleteGym(int id) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;

    return _database.writeTxn(() async {
      final gym = await _database.gyms.get(id);
      if (gym == null ||
          gym.userId != userId ||
          !_ownershipContext.isCurrentUser(userId)) {
        return null;
      }
      await _database.equipments.filter().gymIdEqualTo(gym.gymId).deleteAll();
      await _database.gyms.delete(id);
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while deleting the gym.');
      }
      return gym;
    });
  }

  // -------------------- Lookups ---------------------------------------------

  /// Get by Isar id.
  Future<Gym?> getByIsarId(int isarId) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;
    final gym = await _database.gyms.get(isarId);
    if (!_ownershipContext.isCurrentUser(userId) || gym?.userId != userId) {
      return null;
    }
    return gym;
  }

  /// Get by your human-readable gymId (e.g., "GYM-0001").
  Future<Gym?> getByGymId(String gymId) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;
    final gym =
        await _database.gyms
            .filter()
            .userIdEqualTo(userId)
            .and()
            .gymIdEqualTo(gymId)
            .findFirst();
    if (!_ownershipContext.isCurrentUser(userId)) return null;
    return gym;
  }

  /// True if a gym with this gymId exists for the user (helps validate selection).
  Future<bool> existsForUser(String userId, String gymId) async {
    if (!_ownershipContext.isCurrentUser(userId)) return false;
    final count =
        await _database.gyms
            .filter()
            .userIdEqualTo(userId)
            .and()
            .gymIdEqualTo(gymId)
            .count();
    return _ownershipContext.isCurrentUser(userId) && count > 0;
  }

  // -------------------- Lists (search / sort) --------------------------------

  /// List all gyms for a user, with optional text search and sorting.
  ///
  /// `search` matches against name and location (case-insensitive).
  Future<List<Gym>> getAllForUser(
    String userId, {
    String? search,
    GymSort sort = GymSort.nameAsc,
  }) async {
    if (!_ownershipContext.isCurrentUser(userId)) return [];

    // Base fetch (fast due to your userId index)
    var items = await _database.gyms.filter().userIdEqualTo(userId).findAll();
    if (!_ownershipContext.isCurrentUser(userId)) return [];

    // Local, case-insensitive search
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      items =
          items.where((g) {
            final n = g.name.toLowerCase();
            final loc = (g.location ?? '').toLowerCase();
            return n.contains(q) || loc.contains(q);
          }).toList();
    }

    // Dart-side sorting (avoids relying on generated sort helpers)
    int cmpDate(DateTime a, DateTime b) => a.compareTo(b);

    switch (sort) {
      case GymSort.nameAsc:
        items.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case GymSort.nameDesc:
        items.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case GymSort.newest:
        items.sort((a, b) => cmpDate(b.createdDate, a.createdDate));
        break;
      case GymSort.oldest:
        items.sort((a, b) => cmpDate(a.createdDate, b.createdDate));
        break;
    }

    return items;
  }

  // -------------------- Stats ------------------------------------------------

  /// Count gyms for a user (useful for dashboard tiles).
  Future<int> countForUser(String userId) async {
    if (!_ownershipContext.isCurrentUser(userId)) return 0;
    final count = await _database.gyms.filter().userIdEqualTo(userId).count();
    return _ownershipContext.isCurrentUser(userId) ? count : 0;
  }

  /// Insert or replace a gym.
  Future<void> upsert(Gym gym) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null || gym.userId != userId) {
      throw StateError('An authenticated owner is required to save a gym.');
    }

    await _database.writeTxn(() async {
      final existing = await _database.gyms.get(gym.id);
      if (existing != null && existing.userId != userId) {
        throw StateError('The gym does not belong to the current user.');
      }
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while saving the gym.');
      }
      await _database.gyms.put(gym);
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while saving the gym.');
      }
    });
  }

  Future<List<Gym>> getAllForCurrentUser() async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return [];
    return getAllForUser(userId);
  }
}
