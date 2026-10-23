import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';

/// Query functions for Equipment filtering
class EquipmentQueries {
  static Future<List<Equipment>> _getAllForCurrentUser() =>
      EquipmentRepository().getAllForCurrentUser();

  /// Get equipment items by category
  static Future<List<Equipment>> getByCategory(
    EquipmentCategory category,
  ) async {
    final items = await _getAllForCurrentUser();
    return items.where((item) => item.category == category).toList();
  }

  /// Get equipment items by condition
  static Future<List<Equipment>> getByCondition(
    EquipmentCondition condition,
  ) async {
    final items = await _getAllForCurrentUser();
    return items.where((item) => item.condition == condition).toList();
  }

  /// Get equipment items by purchase date
  static Future<List<Equipment>> getByPurchaseDate(
    DateTime purchaseDate,
  ) async {
    final items = await _getAllForCurrentUser();
    return items.where((item) => item.purchaseDate == purchaseDate).toList();
  }

  /// Get equipment items by brand
  static Future<List<Equipment>> getByBrand(String brand) async {
    final items = await _getAllForCurrentUser();
    return items.where((item) => item.brand == brand).toList();
  }

  /// Get equipment items by training style
  static Future<List<Equipment>> getByTrainingStyle(
    TrainingStyle trainingStyle,
  ) async {
    final items = await _getAllForCurrentUser();
    return items.where((item) => item.trainingStyle == trainingStyle).toList();
  }
}
