import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';

import 'isar_test_util.dart';

void main() {
  late Isar isar;
  late GymRepository repo;

  setUpAll(() async {
    isar = await openIsarTestInstance();
    await IsarService.initForTesting(instance: isar);
    repo = GymRepository();
  });

  tearDown(() async {
    // If clearIsar is not defined, you may need to clear manually or remove this line
    // await clearIsar(isar);
  });

  group('GymRepository CRUD', () {
    test('create → read by id', () async {
      final created = await repo.createGym(
        gymId: 'GYM-001',
        name: 'Test Gym',
        userId: 'user1',
      );
      final fetched = await repo.getByIsarId(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Test Gym'));
      expect(fetched.gymId, equals('GYM-001'));
    });

    test('update gym', () async {
      final g = await repo.createGym(gymId: 'GYM-002', name: 'Before', userId: 'user1');
      // Update by changing name and upserting
      final updatedGym = Gym(
        id: g.id,
        gymId: g.gymId,
        name: 'After',
        userId: g.userId,
        location: g.location,
        gymNotes: g.gymNotes,
        createdDate: g.createdDate,
      );
      await repo.upsert(updatedGym);
      final fetched = await repo.getByIsarId(g.id);
      expect(fetched!.name, equals('After'));
    });

    test('delete gym', () async {
      final g = await repo.createGym(gymId: 'GYM-003', name: 'To Delete', userId: 'user1');
      await repo.deleteByIsarId(g.id);
      final fetched = await repo.getByIsarId(g.id);
      expect(fetched, isNull);
    });
  });

  group('GymRepository lists & lookups', () {
    test('get all gyms returns sorted list (by name)', () async {
      await repo.createGym(gymId: 'GYM-010', name: 'Beta', userId: 'user1');
      await repo.createGym(gymId: 'GYM-009', name: 'Alpha', userId: 'user1');
      await repo.createGym(gymId: 'GYM-011', name: 'Charlie', userId: 'user1');
      final all = await repo.getAllForUser('user1');
      expect(all.length, 3);
      expect(all.map((g) => g.name).toList(), equals(['Alpha', 'Beta', 'Charlie']));
    });

    test('get gym by gymId (custom id like GYM-001)', () async {
      await repo.createGym(gymId: 'GYM-100', name: 'Lookup Gym', userId: 'user1');
      final fetched = await repo.getByGymId('GYM-100');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Lookup Gym');
    });
  });

  group('GymRepository constraints', () {
    test('prevent duplicate gymId', () async {
      await repo.createGym(gymId: 'GYM-200', name: 'Original', userId: 'user1');
      try {
        await repo.createGym(gymId: 'GYM-200', name: 'Duplicate', userId: 'user1');
        fail('Expected unique constraint violation for gymId');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
