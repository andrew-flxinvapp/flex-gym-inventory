import 'dart:async';
import 'dart:io';

import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/service/ownership_context.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late EquipmentRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fgi_equipment_sync');
    isar = await Isar.open(
      [GymSchema, EquipmentSchema],
      directory: directory.path,
      name: 'equipment_sync',
    );
    repository = EquipmentRepository(
      isar: isar,
      ownershipContext: OwnershipContext(currentUserIdReader: () => 'user-a'),
    );

    await isar.writeTxn(() async {
      await isar.gyms.put(_gym('gym-a'));
      await isar.gyms.put(_gym('gym-b'));
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  test('selected gym watcher emits after create and delete', () async {
    final gym = await isar.gyms.filter().gymIdEqualTo('gym-a').findFirst();
    expect(gym, isNotNull);

    final changes = StreamIterator(repository.watchForGym(gym!));
    try {
      final createNotification = changes.moveNext();
      final first = await _createEquipment(
        repository,
        gymId: gym.gymId,
        name: 'Dumbbell',
        quantity: 2,
        value: 25,
      );
      expect(
        await createNotification.timeout(const Duration(seconds: 2)),
        isTrue,
      );

      final firstLoad = await repository.getAllForGym(gym.gymId);
      expect(firstLoad.map((item) => item.id), [first.id]);
      expect(firstLoad.fold<int>(0, (sum, item) => sum + item.quantity), 2);
      expect(
        firstLoad.fold<double>(
          0,
          (sum, item) => sum + (item.value ?? 0) * item.quantity,
        ),
        50,
      );

      final addAnotherNotification = changes.moveNext();
      final second = await _createEquipment(
        repository,
        gymId: gym.gymId,
        name: 'Barbell',
        quantity: 1,
        value: 100,
      );
      expect(
        await addAnotherNotification.timeout(const Duration(seconds: 2)),
        isTrue,
      );

      final populated = await repository.getAllForGym(gym.gymId);
      expect(populated, hasLength(2));
      expect(populated.fold<int>(0, (sum, item) => sum + item.quantity), 3);
      expect(
        populated.fold<double>(
          0,
          (sum, item) => sum + (item.value ?? 0) * item.quantity,
        ),
        150,
      );

      final deleteOneNotification = changes.moveNext();
      expect(await repository.deleteEquipment(first.id), isNotNull);
      expect(
        await deleteOneNotification.timeout(const Duration(seconds: 2)),
        isTrue,
      );

      final afterOneDelete = await repository.getAllForGym(gym.gymId);
      expect(afterOneDelete.map((item) => item.id), [second.id]);
      expect(
        afterOneDelete.fold<int>(0, (sum, item) => sum + item.quantity),
        1,
      );
      expect(
        afterOneDelete.fold<double>(
          0,
          (sum, item) => sum + (item.value ?? 0) * item.quantity,
        ),
        100,
      );

      final deleteFinalNotification = changes.moveNext();
      expect(await repository.deleteEquipment(second.id), isNotNull);
      expect(
        await deleteFinalNotification.timeout(const Duration(seconds: 2)),
        isTrue,
      );
      expect(await repository.getAllForGym(gym.gymId), isEmpty);
    } finally {
      await changes.cancel();
    }
  });

  test('gym watcher ignores equipment changes in another gym', () async {
    final gymA = await isar.gyms.filter().gymIdEqualTo('gym-a').findFirst();
    expect(gymA, isNotNull);

    final notified = Completer<void>();
    var notificationCount = 0;
    final subscription = repository.watchForGym(gymA!).listen((_) {
      notificationCount++;
      if (!notified.isCompleted) notified.complete();
    });
    try {
      await _createEquipment(
        repository,
        gymId: 'gym-b',
        name: 'Other gym item',
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(notificationCount, 0);

      await _createEquipment(
        repository,
        gymId: gymA.gymId,
        name: 'Selected gym item',
      );
      await notified.future.timeout(const Duration(seconds: 2));
      expect(notificationCount, 1);
      expect(
        (await repository.getAllForGym(gymA.gymId)).map((item) => item.name),
        ['Selected gym item'],
      );
    } finally {
      await subscription.cancel();
    }
  });
}

Gym _gym(String gymId) => Gym(
  userId: 'user-a',
  gymId: gymId,
  name: gymId,
  createdDate: DateTime(2026),
);

Future<Equipment> _createEquipment(
  EquipmentRepository repository, {
  required String gymId,
  required String name,
  int quantity = 1,
  double? value,
}) {
  return repository.createEquipment(
    gymId: gymId,
    name: name,
    category: EquipmentCategory.weights,
    brand: 'Brand',
    model: 'Model',
    trainingStyle: TrainingStyle.general,
    quantity: quantity,
    condition: EquipmentCondition.good,
    value: value,
  );
}
