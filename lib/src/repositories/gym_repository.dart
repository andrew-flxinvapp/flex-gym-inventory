import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';

class GymRepository {
  /// Create a new gym
  Future<void> addGym(Gym gym) async {
    final isar = await IsarService.instance;
    await isar.writeTxn(() async {
      await isar.gyms.put(gym);
    });
  }

  /// Get all gyms for a specific user
  Future<List<Gym>> getAllForUser(String userId) async {
    final isar = await IsarService.instance;
    return isar.gyms.filter().userIdEqualTo(userId).sortByName().findAll();
  }

  /// Get a gym by its gymId (your GYM-001 identifier)
  Future<Gym?> getByGymId(String gymId) async {
    final isar = await IsarService.instance;
    return isar.gyms.where().gymIdEqualTo(gymId).findFirst();
  }

  /// Delete a gym
  Future<void> deleteGym(int isarId) async {
    final isar = await IsarService.instance;
    await isar.writeTxn(() async {
      await isar.gyms.delete(isarId);
    });
  }

  /// Check if a gym exitsts for a user (helps validate default selection)
  Future<bool> exitstForUser(String userId, String gymId) async {
    final isar = await IsarService.instance;
    final count = await isar.gyms
        .filter()
        .userIdEqualTo(userId)
        .and()
        .gymIdEqualTo(gymId)
        .count();
    return count > 0;
  }
}