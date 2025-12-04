import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/repositories/equipment_repository.dart';
import '../helpers/isar_test_util.dart';

void main() {
  late Isar isar;
  late EquipmentRepository repo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    isar = await openIsarTestInstance();
    await IsarService.initForTesting(instance: isar);
    repo = EquipmentRepository();
  });

  tearDownAll(() async {
    // Close the test Isar instance when all tests complete
    await isar.close();
  });

  group('EquipmentRepository CRUD', () {
    test('create → read by id', () async {
      final created = await repo.createEquipment(
        gymId: 'GYM-001',
        name: 'Dumbbell',
        category: EquipmentCategory.weights,
        brand: 'Rogue',
        model: 'DB-20',
        trainingStyle: TrainingStyle.general,
        quantity: 2,
        condition: EquipmentCondition.brandNew,
      );
      final fetched = await repo.getByIsarId(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Dumbbell'));
    });

    test('update equipment', () async {
      final eq = await repo.createEquipment(
        gymId: 'GYM-002',
        name: 'Barbell',
        category: EquipmentCategory.weights,
        brand: 'Eleiko',
        model: 'BB-20',
        trainingStyle: TrainingStyle.general,
        quantity: 1,
        condition: EquipmentCondition.good,
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
        category: EquipmentCategory.weights,
        brand: 'Onnit',
        model: 'KB-16',
        trainingStyle: TrainingStyle.general,
        quantity: 1,
        condition: EquipmentCondition.brandNew,
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
        category: EquipmentCategory.benches,
        brand: 'Rogue',
        model: 'BN-01',
        trainingStyle: TrainingStyle.general,
        quantity: 1,
        condition: EquipmentCondition.brandNew,
      );
      await repo.createEquipment(
        gymId: 'GYM-010',
        name: 'Squat Rack',
        category: EquipmentCategory.racks,
        brand: 'Rogue',
        model: 'SR-01',
        trainingStyle: TrainingStyle.general,
        quantity: 1,
        condition: EquipmentCondition.brandNew,
      );
      await repo.createEquipment(
        gymId: 'GYM-010',
        name: 'Ab Roller',
        category: EquipmentCategory.accessories,
        brand: 'Perfect Fitness',
        model: 'AR-01',
        trainingStyle: TrainingStyle.general,
        quantity: 1,
        condition: EquipmentCondition.brandNew,
      );
      final all = await repo.getAllForGym('GYM-010');
      expect(all.length, 3);
      expect(all.map((e) => e.name).toList(), equals(['Ab Roller', 'Bench', 'Squat Rack']));
    });
  });
}
