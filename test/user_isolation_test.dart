import 'dart:io';

import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/service/active_gym_service.dart';
import 'package:flex_gym_inventory/service/ownership_context.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/data/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/data/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/src/models/app_state_model.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late String? authenticatedUserId;
  late OwnershipContext ownershipContext;
  late GymRepository gymRepository;
  late EquipmentRepository equipmentRepository;
  late WishlistRepository wishlistRepository;
  late ActiveGymService activeGymService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fgi_user_isolation');
    isar = await Isar.open(
      [GymSchema, EquipmentSchema, WishlistSchema, AppStateSchema],
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
    wishlistRepository = WishlistRepository(
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
    'users can access, update, and delete their own Wishlist items',
    () async {
      final item = await _createWishlist(
        wishlistRepository,
        userId: 'account-a',
        name: 'Account A rack',
      );

      expect(await wishlistRepository.getByIsarId(item.id), isNotNull);
      expect((await wishlistRepository.getAll()).single.userId, 'account-a');
      expect(await wishlistRepository.countAll(), 1);

      final updated = await wishlistRepository.updateWishlist(
        id: item.id,
        name: 'Updated rack',
      );
      expect(updated?.name, 'Updated rack');

      final deleted = await wishlistRepository.deleteWishlist(item.id);
      expect(deleted?.userId, 'account-a');
      expect(await wishlistRepository.getByIsarId(item.id), isNull);
      expect(await wishlistRepository.countAll(), 0);
    },
  );

  test('Wishlist access stays isolated when switching accounts', () async {
    final itemA = await _createWishlist(
      wishlistRepository,
      userId: 'account-a',
      name: 'Account A rack',
    );

    authenticatedUserId = 'account-b';
    final itemB = await _createWishlist(
      wishlistRepository,
      userId: 'account-b',
      name: 'Account B bench',
    );

    expect((await wishlistRepository.getAll()).map((item) => item.id), [
      itemB.id,
    ]);
    expect(await wishlistRepository.getByIsarId(itemA.id), isNull);
    expect(
      await wishlistRepository.updateWishlist(id: itemA.id, name: 'Stolen'),
      isNull,
    );
    expect(await wishlistRepository.deleteWishlist(itemA.id), isNull);
    await expectLater(
      wishlistRepository.upsert(itemA),
      throwsA(isA<StateError>()),
    );
    expect((await isar.wishlists.get(itemA.id))?.name, 'Account A rack');

    authenticatedUserId = 'account-a';
    expect((await wishlistRepository.getAll()).map((item) => item.id), [
      itemA.id,
    ]);
    expect(await wishlistRepository.getByIsarId(itemB.id), isNull);
  });

  test('unauthenticated Wishlist access fails closed', () async {
    final item = await _createWishlist(
      wishlistRepository,
      userId: 'account-a',
      name: 'Private rack',
    );
    authenticatedUserId = null;

    expect(await wishlistRepository.getAll(), isEmpty);
    expect(await wishlistRepository.getByIsarId(item.id), isNull);
    expect(await wishlistRepository.countAll(), 0);
    expect(
      await wishlistRepository.updateWishlist(id: item.id, name: 'Changed'),
      isNull,
    );
    expect(await wishlistRepository.deleteWishlist(item.id), isNull);
    await wishlistRepository.deleteByIsarId(item.id);
    await expectLater(
      wishlistRepository.createWishlist(
        userId: 'local',
        name: 'Offline rack',
        wishlistType: WishlistType.newItem,
        category: EquipmentCategory.racks,
        brand: 'Brand',
        priority: WishlistPriority.high,
      ),
      throwsA(isA<StateError>()),
    );
    expect((await isar.wishlists.get(item.id))?.name, 'Private rack');
  });

  test('legacy local Wishlist records remain private', () async {
    final legacyItem = Wishlist(
      userId: 'local',
      name: 'Legacy rack',
      wishlistType: WishlistType.newItem,
      category: EquipmentCategory.racks,
      brand: 'Brand',
      priority: WishlistPriority.high,
    );
    await isar.writeTxn(() async {
      await isar.wishlists.put(legacyItem);
    });

    expect(await wishlistRepository.getAll(), isEmpty);
    expect(await wishlistRepository.getByIsarId(legacyItem.id), isNull);
    expect(
      await wishlistRepository.updateWishlist(
        id: legacyItem.id,
        name: 'Reassigned',
      ),
      isNull,
    );
    expect(await wishlistRepository.deleteWishlist(legacyItem.id), isNull);
    expect((await isar.wishlists.get(legacyItem.id))?.userId, 'local');
  });

  test(
    'Wishlist mutations roll back if authentication changes mid-transaction',
    () async {
      final item = await _createWishlist(
        wishlistRepository,
        userId: 'account-a',
        name: 'Stable rack',
      );
      var identityReads = 0;
      final changingContext = OwnershipContext(
        currentUserIdReader: () {
          identityReads++;
          return identityReads >= 3 ? 'account-b' : 'account-a';
        },
      );
      final changingRepository = WishlistRepository(
        isar: isar,
        ownershipContext: changingContext,
      );

      await expectLater(
        changingRepository.updateWishlist(id: item.id, name: 'Changed'),
        throwsA(isA<StateError>()),
      );
      expect((await isar.wishlists.get(item.id))?.name, 'Stable rack');

      identityReads = 0;
      await expectLater(
        changingRepository.deleteWishlist(item.id),
        throwsA(isA<StateError>()),
      );
      expect((await isar.wishlists.get(item.id))?.name, 'Stable rack');
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

Future<Wishlist> _createWishlist(
  WishlistRepository repository, {
  required String userId,
  required String name,
}) {
  return repository.createWishlist(
    userId: userId,
    name: name,
    wishlistType: WishlistType.newItem,
    category: EquipmentCategory.racks,
    brand: 'Brand',
    priority: WishlistPriority.high,
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
