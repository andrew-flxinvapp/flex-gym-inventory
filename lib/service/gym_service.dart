import 'package:isar/isar.dart';
import '../src/models/gym_model.dart';

/// Service for CRUD operations on gyms in Isar DB.
class GymService {
  final Isar isar;
  GymService(this.isar);

  Future<void> addGym(Gym gym) async {
    await isar.writeTxn(() async {
      await isar.gyms.put(gym);
    });
  }

  Future<List<Gym>> getAllGyms() async {
    return await isar.gyms.where().findAll();
  }

  Future<void> updateGym(Gym gym) async {
    await isar.writeTxn(() async {
      await isar.gyms.put(gym);
    });
  }

  Future<void> deleteGym(int id) async {
    await isar.writeTxn(() async {
      await isar.gyms.delete(id);
    });
  }
}
