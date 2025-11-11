import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/repositories/wishlist_repository.dart';
import '../helpers/isar_test_util.dart';

void main() {
  late Isar isar;
  late WishlistRepository repo;

  setUpAll(() async {
    isar = await openIsarTestInstance();
    await IsarService.initForTesting(instance: isar);
    repo = WishlistRepository();
  });

  tearDown(() async {
    // Optionally clear test data between tests
    // await clearIsarTestInstance(isar);
  });

  group('WishlistRepository CRUD', () {
    test('create → read by id', () async {
      final created = await repo.createWishlist(
        name: 'Power Rack',
        wishlistType: 'Equipment',
        category: 'Racks',
        brand: 'Rogue',
        priority: 'High',
      );
      final fetched = await repo.getByIsarId(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Power Rack'));
      expect(fetched.priority, equals('High'));
    });

    test('update wishlist item', () async {
      final item = await repo.createWishlist(
        name: 'Barbell',
        wishlistType: 'Equipment',
        category: 'Free Weights',
        brand: 'Eleiko',
        priority: 'Medium',
      );
      item.name = 'Barbell Pro';
      item.priority = 'High';
      await repo.upsert(item);
      final fetched = await repo.getByIsarId(item.id);
      expect(fetched!.name, equals('Barbell Pro'));
      expect(fetched.priority, equals('High'));
    });

    test('delete wishlist item', () async {
      final item = await repo.createWishlist(
        name: 'Kettlebell',
        wishlistType: 'Equipment',
        category: 'Free Weights',
        brand: 'Onnit',
        priority: 'Low',
      );
      await repo.deleteWishlist(item.id);
      final fetched = await repo.getByIsarId(item.id);
      expect(fetched, isNull);
    });
  });

  group('WishlistRepository lists & lookups', () {
    test('get all wishlist items returns sorted list (by name)', () async {
      await repo.createWishlist(
        name: 'Bench',
        wishlistType: 'Equipment',
        category: 'Benches',
        brand: 'Rogue',
        priority: 'Medium',
      );
      await repo.createWishlist(
        name: 'Squat Rack',
        wishlistType: 'Equipment',
        category: 'Racks',
        brand: 'Rogue',
        priority: 'High',
      );
      await repo.createWishlist(
        name: 'Ab Roller',
        wishlistType: 'Equipment',
        category: 'Core',
        brand: 'Perfect Fitness',
        priority: 'Low',
      );
      final all = await repo.getAll();
      expect(all.length, greaterThanOrEqualTo(3));
      expect(all.map((w) => w.name).toList().sublist(0, 3), equals(['Ab Roller', 'Bench', 'Squat Rack']));
    });
  });
}
