import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
// import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/repositories/equipment_repository.dart';
import '../helpers/isar_test_util.dart';

void main() {
  late Isar isar;
  late EquipmentRepository repo;

  setUpAll(() async {
    isar = await openIsarTestInstance();
    await IsarService.initForTesting(instance: isar);
    repo = EquipmentRepository();
  });

  tearDown(() async {
    // Optionally clear test data between tests
    // await clearIsarTestInstance(isar);
  });

  group('EquipmentRepository CRUD', () {
    test('create → read by id', () async {
      final created = await repo.createEquipment(
        gymId: 'GYM-001',
        name: 'Dumbbell',
        category: 'Free Weights',
        brand: 'Rogue',
        model: 'DB-20',
        trainingStyle: 'Strength',
        quantity: 2,
        condition: 'New',
      );
      final fetched = await repo.getByIsarId(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Dumbbell'));
    });

    test('update equipment', () async {
      final eq = await repo.createEquipment(
        gymId: 'GYM-002',
        name: 'Barbell',
        category: 'Free Weights',
        brand: 'Eleiko',
        model: 'BB-20',
        trainingStyle: 'Strength',
        quantity: 1,
        condition: 'Used',
      );
      eq.name = 'Barbell Pro';
      await repo.upsert(eq);
      final fetched = await repo.getByIsarId(eq.id);
      expect(fetched!.name, equals('Barbell Pro'));
    });

    test('delete equipment', () async {
      final eq = await repo.createEquipment(
        gymId: 'GYM-003',
        name: 'Kettlebell',
        category: 'Free Weights',
        brand: 'Onnit',
        model: 'KB-16',
        trainingStyle: 'Strength',
        quantity: 1,
        condition: 'New',
      );
      await repo.deleteEquipment(eq.id);
      final fetched = await repo.getByIsarId(eq.id);
      expect(fetched, isNull);
    });
  });

  group('EquipmentRepository lists & lookups', () {
    test('get all equipment returns sorted list (by name)', () async {
      await repo.createEquipment(
        gymId: 'GYM-010',
        name: 'Bench',
        category: 'Benches',
        brand: 'Rogue',
        model: 'BN-01',
        trainingStyle: 'Strength',
        quantity: 1,
        condition: 'New',
      );
      await repo.createEquipment(
        gymId: 'GYM-010',
        name: 'Squat Rack',
        category: 'Racks',
        brand: 'Rogue',
        model: 'SR-01',
        trainingStyle: 'Strength',
        quantity: 1,
        condition: 'New',
      );
      await repo.createEquipment(
        gymId: 'GYM-010',
        name: 'Ab Roller',
        category: 'Core',
        brand: 'Perfect Fitness',
        model: 'AR-01',
        trainingStyle: 'Core',
        quantity: 1,
        condition: 'New',
      );
      final all = await repo.getAllForGym('GYM-010');
      expect(all.length, 3);
      expect(all.map((e) => e.name).toList(), equals(['Ab Roller', 'Bench', 'Squat Rack']));
    });
  });
}
