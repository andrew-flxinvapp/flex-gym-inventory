import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';

/// Opens a temporary Isar instance for testing.
/// Each test run gets its own isolated instance so data doesn't persist
/// between tests or affect the production storage.
/// Usage: Call openIsarTestInstance() in setUpAll, and clearIsarTestInstance() in tearDown.
Future<Isar> openIsarTestInstance() async {
  try {
    final dir = await getTemporaryDirectory();
    return await Isar.open(
      [
        GymSchema,
        EquipmentSchema,
        WishlistSchema,
      ],
      directory: dir.path,
      name: 'test_isar',
    );
  } catch (e) {
    print('Error opening Isar test instance: $e');
    rethrow;
  }
}

/// Clears all collections between tests.
/// Useful for ensuring a clean state when running multiple test cases.
Future<void> clearIsarTestInstance(Isar isar) async {
  try {
    await isar.writeTxn(() async {
      await isar.gyms.clear();
      await isar.equipments.clear();
      await isar.wishlists.clear();
    });
  } catch (e) {
    print('Error clearing Isar test instance: $e');
    rethrow;
  }
}

/// Closes the Isar instance after tests are complete.
Future<void> closeIsarTestInstance(Isar isar) async {
  try {
    await isar.close();
  } catch (e) {
    print('Error closing Isar test instance: $e');
    rethrow;
  }
}
