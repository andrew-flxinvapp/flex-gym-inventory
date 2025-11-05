import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../src/models/gym_model.dart';
import '../src/models/equipment_model.dart';
import '../src/models/wishlist_model.dart';

/// Service to initialize and provide a singleton Isar instance.
class IsarService {
  static Isar? _isar;

  /// Initialize Isar with all collections. Call this before using any Isar operations.
  static Future<Isar> openIsar() async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      GymSchema,
      EquipmentSchema,
      WishlistSchema,
    ], directory: dir.path);
    return _isar!;
  }

  /// For testing: set the Isar instance directly.
  static Future<void> initForTesting({required Isar instance}) async {
    _isar = instance;
  }

  /// Get the current Isar instance. Throws if not initialized.
  static Isar get isar {
    if (_isar == null) {
      throw Exception('Isar has not been initialized. Call openIsar() first.');
    }
    return _isar!;
  }
}
