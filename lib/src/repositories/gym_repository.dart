import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';

/// Sort modes that map to your fields.
enum GymSort { nameAsc, nameDesc, newest, oldest }

class GymRepository {
  // -------------------- Create / Update / Delete -----------------------------

  /// Create a new gym and insert it.
  Future<Gym> createGym({
    required String gymId,
    required String name,
    required String userId,
    String? location,
    String? gymNotes,
  }) async {
    final gym = Gym(
      gymId: gymId,
      name: name,
      userId: userId,
      location: location,
      gymNotes: gymNotes,
      createdDate: DateTime.now(),
    );
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
    final isar = IsarService.isar;
    final gym = await isar.gyms.get(id);
    if (gym == null) return null;
    if (name != null) gym.name = name;
    if (location != null) gym.location = location;
    if (gymNotes != null) gym.gymNotes = gymNotes;
    await upsert(gym);
    return gym;
  }

  /// Delete a gym by Isar id and return the deleted gym.
  Future<Gym?> deleteGym(int id) async {
    final isar = IsarService.isar;
    final gym = await isar.gyms.get(id);
    if (gym == null) return null;
    await isar.writeTxn(() async {
      await isar.gyms.delete(id);
    });
    return gym;
  }

  // -------------------- Lookups ---------------------------------------------

  /// Get by Isar id.
  Future<Gym?> getByIsarId(int isarId) async {
    final isar = IsarService.isar;
    return isar.gyms.get(isarId);
  }

  /// Get by your human-readable gymId (e.g., "GYM-0001").
  Future<Gym?> getByGymId(String gymId) async {
    final isar = IsarService.isar;
    return isar.gyms
        .filter()
        .gymIdEqualTo(gymId)
        .findFirst();
  }

  /// True if a gym with this gymId exists for the user (helps validate selection).
  Future<bool> existsForUser(String userId, String gymId) async {
    final isar = IsarService.isar;
    final count = await isar.gyms
        .filter()
        .userIdEqualTo(userId)
        .and()
        .gymIdEqualTo(gymId)
        .count();
    return count > 0;
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
    final isar = IsarService.isar;

    // Base fetch (fast due to your userId index)
    var items = await isar.gyms
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    // Local, case-insensitive search
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      items = items.where((g) {
        final n = g.name.toLowerCase();
        final loc = (g.location ?? '').toLowerCase();
        return n.contains(q) || loc.contains(q);
      }).toList();
    }

    // Dart-side sorting (avoids relying on generated sort helpers)
    int cmpDate(DateTime a, DateTime b) => a.compareTo(b);

    switch (sort) {
      case GymSort.nameAsc:
        items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case GymSort.nameDesc:
        items.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
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
    final isar = IsarService.isar;
    return isar.gyms.filter().userIdEqualTo(userId).count();
  }

  /// Insert or replace a gym.
  Future<void> upsert(Gym gym) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.gyms.put(gym);
    });
  }
}
