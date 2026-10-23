import 'package:isar/isar.dart';
import '../src/data/repositories/gym_repository.dart';
import '../src/models/gym_model.dart';
import 'ownership_context.dart';

/// Service for CRUD operations on gyms in Isar DB.
class GymService {
  GymService(Isar isar, {OwnershipContext? ownershipContext})
    : _repository = GymRepository(
        isar: isar,
        ownershipContext: ownershipContext,
      );

  final GymRepository _repository;

  Future<void> addGym(Gym gym) async {
    await _repository.upsert(gym);
  }

  Future<List<Gym>> getAllGyms() async {
    return _repository.getAllForCurrentUser();
  }

  Future<void> updateGym(Gym gym) async {
    await _repository.updateGym(
      id: gym.id,
      name: gym.name,
      location: gym.location,
      gymNotes: gym.gymNotes,
    );
  }

  Future<void> deleteGym(int id) async {
    await _repository.deleteGym(id);
  }
}
