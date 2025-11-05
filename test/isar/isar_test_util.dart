import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';

/// Opens a temporary Isar instance for testing.
/// Each test run gets its own isolated instance so data doesn't persist
/// between tests or affect the production storage.

Future<Isar> openIsarTestInstance() async {
  final dir = await getTemporaryDirectory();
  return Isar.open(
    [
      GymSchema,
      EquipmentSchema,
      WishlistSchema,
    ],
    directory: dir.path,
    name: 'test_isar',
  );
}

/// Clears all collections between tests.
/// Useful for ensuring a clean state when running multiple test cases.

Future<void> clearIsarTestInstance(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.gyms.clear();
    await isar.equipments.clear();
    await isar.wishlists.clear();
  });
}