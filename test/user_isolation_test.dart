import 'dart:io';

import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/service/active_gym_service.dart';
import 'package:flex_gym_inventory/service/ownership_context.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/data/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/models/app_state_model.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late String? authenticatedUserId;
  late OwnershipContext ownershipContext;
  late GymRepository gymRepository;
  late EquipmentRepository equipmentRepository;
  late ActiveGymService activeGymService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fgi_user_isolation');
    isar = await Isar.open(
      [GymSchema, EquipmentSchema, AppStateSchema],
      directory: directory.path,
      name: 'user_isolation',
    );
    authenticatedUserId = 'account-a';
    ownershipContext = OwnershipContext(
      currentUserIdReader: () => authenticatedUserId,
    );
    gymRepository = GymRepository(
      isar: isar,
      ownershipContext: ownershipContext,
    );
    equipmentRepository = EquipmentRepository(
      isar: isar,
      ownershipContext: ownershipContext,
    );
    activeGymService = ActiveGymService(
      isar,
      ownershipContext: ownershipContext,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  test(
    'users can access their own records but not another user records',
    () async {
      final gymA = await _createGym(gymRepository, 'account-a', 'gym-a');
      final equipmentA = await _createEquipment(equipmentRepository, 'gym-a');
      expect(await activeGymService.setActiveGymId('gym-a'), isTrue);

      authenticatedUserId = 'account-b';
      final gymB = await _createGym(gymRepository, 'account-b', 'gym-b');
      final equipmentB = await _createEquipment(equipmentRepository, 'gym-b');

      expect(await gymRepository.getByIsarId(gymA.id), isNull);
      expect(await gymRepository.getByGymId('gym-a'), isNull);
      expect(await gymRepository.getAllForUser('account-a'), isEmpty);
      expect(
        await gymRepository.updateGym(id: gymA.id, name: 'stolen'),
        isNull,
      );
      expect(await gymRepository.deleteGym(gymA.id), isNull);
      await expectLater(gymRepository.upsert(gymA), throwsA(isA<StateError>()));
      expect(await equipmentRepository.getByIsarId(equipmentA.id), isNull);
      expect(await equipmentRepository.getAllForGym('gym-a'), isEmpty);
      expect(
        await equipmentRepository.updateEquipment(
          id: equipmentA.id,
          name: 'stolen',
        ),
        isNull,
      );
      expect(await equipmentRepository.deleteEquipment(equipmentA.id), isNull);
      await expectLater(
        equipmentRepository.upsert(equipmentA),
        throwsA(isA<StateError>()),
      );
      expect(await activeGymService.setActiveGymId('gym-a'), isFalse);
      expect((await activeGymService.getActiveGym())?.gymId, 'gym-b');

      final updatedGymB = await gymRepository.updateGym(
        id: gymB.id,
        name: 'Account B Gym Updated',
      );
      final updatedEquipmentB = await equipmentRepository.updateEquipment(
        id: equipmentB.id,
        name: 'Account B Equipment Updated',
      );
      expect(updatedGymB?.name, 'Account B Gym Updated');
      expect(updatedEquipmentB?.name, 'Account B Equipment Updated');
      expect((await gymRepository.deleteGym(gymB.id))?.userId, 'account-b');
      expect(await equipmentRepository.getByIsarId(equipmentB.id), isNull);

      authenticatedUserId = 'account-a';
      expect((await gymRepository.getByGymId('gym-a'))?.userId, 'account-a');
      expect(
        (await equipmentRepository.getByIsarId(equipmentA.id))?.name,
        'Equipment',
      );
      final updatedGymA = await gymRepository.updateGym(
        id: gymA.id,
        name: 'Account A Gym Updated',
      );
      expect(updatedGymA?.name, 'Account A Gym Updated');

      final deletedGymA = await gymRepository.deleteGym(gymA.id);
      expect(deletedGymA?.gymId, 'gym-a');
      expect(await isar.equipments.get(equipmentA.id), isNull);
      expect(await activeGymService.getActiveGym(), isNull);
    },
  );

  test(
    'unauthenticated access fails closed and invalid selection is empty',
    () async {
      await _createGym(gymRepository, 'account-a', 'gym-a');
      authenticatedUserId = null;

      expect(await gymRepository.getAllForCurrentUser(), isEmpty);
      expect(await gymRepository.getByGymId('gym-a'), isNull);
      expect(await equipmentRepository.getAllForGym('gym-a'), isEmpty);
      expect(await activeGymService.getActiveGym(), isNull);
      expect(await activeGymService.setActiveGymId('gym-a'), isFalse);
    },
  );

  test(
    'foreign active ID is not resolved when current user has no gyms',
    () async {
      await _createGym(gymRepository, 'account-a', 'gym-a');
      expect(await activeGymService.setActiveGymId('gym-a'), isTrue);
      authenticatedUserId = 'account-b';

      expect(await activeGymService.getActiveGym(), isNull);
      await expectLater(
        activeGymService.getActiveGymId(),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'equipment can only be created for a gym owned by current user',
    () async {
      await _createGym(gymRepository, 'account-a', 'gym-a');
      authenticatedUserId = 'account-b';

      await expectLater(
        _createEquipment(equipmentRepository, 'gym-a'),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'active selection rolls back if authentication changes before commit',
    () async {
      await _createGym(gymRepository, 'account-a', 'gym-a');

      var racingUserId = 'account-a';
      var authReads = 0;
      final racingOwnershipContext = OwnershipContext(
        currentUserIdReader: () {
          authReads++;
          if (authReads == 3) racingUserId = 'account-b';
          return racingUserId;
        },
      );
      final racingService = ActiveGymService(
        isar,
        ownershipContext: racingOwnershipContext,
      );

      await expectLater(
        racingService.setActiveGymId('gym-a'),
        throwsA(isA<StateError>()),
      );
      expect((await isar.appStates.get(1))?.activeGymId, isNull);
    },
  );
}

Future<Gym> _createGym(GymRepository repository, String userId, String gymId) {
  return repository.createGym(
    gymId: gymId,
    name: 'Gym $userId',
    userId: userId,
  );
}

Future<Equipment> _createEquipment(
  EquipmentRepository repository,
  String gymId,
) {
  return repository.createEquipment(
    gymId: gymId,
    name: 'Equipment',
    category: EquipmentCategory.other,
    brand: 'Brand',
    model: 'Model',
    trainingStyle: TrainingStyle.general,
    quantity: 1,
    condition: EquipmentCondition.good,
  );
}
