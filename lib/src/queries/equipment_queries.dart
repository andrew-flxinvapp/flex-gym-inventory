import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';

/// Query functions for Equipment filtering
class EquipmentQueries {
  /// Get equipment items by category
  static Future<List<Equipment>> getByCategory(EquipmentCategory category) async {
    final isar = IsarService.isar;
    return isar.equipments.filter().categoryEqualTo(category).findAll();
  }

  /// Get equipment items by condition
  static Future<List<Equipment>> getByCondition(EquipmentCondition condition) async {
    final isar = IsarService.isar;
    return isar.equipments.filter().conditionEqualTo(condition).findAll();
  }

  /// Get equipment items by purchase date
  static Future<List<Equipment>> getByPurchaseDate(DateTime purchaseDate) async {
    final isar = IsarService.isar;
    return isar.equipments.filter().purchaseDateEqualTo(purchaseDate).findAll();
  }

  /// Get equipment items by brand
  static Future<List<Equipment>> getByBrand(String brand) async {
    final isar = IsarService.isar;
    return isar.equipments.filter().brandEqualTo(brand).findAll();
  }

  /// Get equipment items by training style
  static Future<List<Equipment>> getByTrainingStyle(TrainingStyle trainingStyle) async {
    final isar = IsarService.isar;
    return isar.equipments.filter().trainingStyleEqualTo(trainingStyle).findAll();
  }
}
