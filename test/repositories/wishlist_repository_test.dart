import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import '../helpers/isar_test_util.dart';

void main() {
  late Isar isar;
  late WishlistRepository repo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    isar = await openIsarTestInstance();
    await IsarService.initForTesting(instance: isar);
    repo = WishlistRepository();
  });

  tearDownAll(() async {
    // Close the test Isar instance when all tests complete
    await isar.close();
  });

  group('WishlistRepository CRUD', () {
    test('create → read by id', () async {
      final created = await repo.createWishlist(
        userId: 'TEST-USER',
        name: 'Power Rack',
        wishlistType: WishlistType.newItem,
        category: EquipmentCategory.racks,
        brand: 'Rogue',
        priority: WishlistPriority.high,
      );
      final fetched = await repo.getByIsarId(created.id);
      expect(fetched, isNotNull);
  expect(fetched!.name, equals('Power Rack'));
  expect(fetched.priority, equals(WishlistPriority.high));
    });

    test('update wishlist item', () async {
      final item = await repo.createWishlist(
        userId: 'TEST-USER',
        name: 'Barbell',
        wishlistType: WishlistType.newItem,
        category: EquipmentCategory.weights,
        brand: 'Eleiko',
        priority: WishlistPriority.medium,
      );
  item.name = 'Barbell Pro';
  item.priority = WishlistPriority.high;
      await repo.upsert(item);
      final fetched = await repo.getByIsarId(item.id);
      expect(fetched!.name, equals('Barbell Pro'));
  expect(fetched.priority, equals(WishlistPriority.high));
    });

    test('delete wishlist item', () async {
      final item = await repo.createWishlist(
        userId: 'TEST-USER',
        name: 'Kettlebell',
        wishlistType: WishlistType.newItem,
        category: EquipmentCategory.weights,
        brand: 'Onnit',
        priority: WishlistPriority.low,
      );
      await repo.deleteWishlist(item.id);
      final fetched = await repo.getByIsarId(item.id);
      expect(fetched, isNull);
    });
  });

  group('WishlistRepository lists & lookups', () {
    test('get all wishlist items returns sorted list (by name)', () async {
      await repo.createWishlist(
        userId: 'TEST-USER',
        name: 'Bench',
        wishlistType: WishlistType.newItem,
        category: EquipmentCategory.benches,
        brand: 'Rogue',
        priority: WishlistPriority.medium,
      );
      await repo.createWishlist(
        userId: 'TEST-USER',
        name: 'Squat Rack',
        wishlistType: WishlistType.newItem,
        category: EquipmentCategory.racks,
        brand: 'Rogue',
        priority: WishlistPriority.high,
      );
      await repo.createWishlist(
        userId: 'TEST-USER',
        name: 'Ab Roller',
        wishlistType: WishlistType.newItem,
        category: EquipmentCategory.accessories,
        brand: 'Perfect Fitness',
        priority: WishlistPriority.low,
      );
      final all = await repo.getAll();
      expect(all.length, greaterThanOrEqualTo(3));
      expect(all.map((w) => w.name).toList().sublist(0, 3), equals(['Ab Roller', 'Bench', 'Squat Rack']));
    });
  });
}
