import 'package:isar/isar.dart';
import '../src/models/wishlist_model.dart';

/// Service for CRUD operations on wishlist items in Isar DB.
class WishlistService {
  final Isar isar;
  WishlistService(this.isar);

  Future<void> addWishlistItem(Wishlist item) async {
    await isar.writeTxn(() async {
      await isar.wishlists.put(item);
    });
  }

  Future<List<Wishlist>> getAllWishlistItems() async {
    return await isar.wishlists.where().findAll();
  }

  Future<void> updateWishlistItem(Wishlist item) async {
    await isar.writeTxn(() async {
      await isar.wishlists.put(item);
    });
  }

  Future<void> deleteWishlistItem(int id) async {
    await isar.writeTxn(() async {
      await isar.wishlists.delete(id);
    });
  }
}
