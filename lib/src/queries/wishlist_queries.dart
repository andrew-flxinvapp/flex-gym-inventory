import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:isar/isar.dart';

/// Query functions for Wishlist filtering
class WishlistQueries {
	/// Get wishlist items by category
	static Future<List<Wishlist>> getByCategory(EquipmentCategory category) async {
		final isar = IsarService.isar;
		return isar.wishlists.filter().categoryEqualTo(category).findAll();
	}

	/// Get wishlist items by brand
	static Future<List<Wishlist>> getByBrand(String brand) async {
		final isar = IsarService.isar;
		return isar.wishlists.filter().brandEqualTo(brand).findAll();
	}

	/// Get wishlist items by priority
	static Future<List<Wishlist>> getByPriority(WishlistPriority priority) async {
		final isar = IsarService.isar;
		return isar.wishlists.filter().priorityEqualTo(priority).findAll();
	}

}
