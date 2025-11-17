import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';

/// Simple sort modes aligned to your fields.
enum EquipmentSort {
  nameAsc,
  nameDesc,
  newestPurchase,
  oldestPurchase,
  valueHighLow,
  valueLowHigh,
}

class EquipmentRepository {
  // -------------------- Create / Update / Delete -----------------------------

  /// Insert or replace an equipment record.
  Future<void> upsert(Equipment equipment) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.equipments.put(equipment);
    });
  }

  /// Delete by Isar id.
  Future<void> deleteByIsarId(int isarId) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.equipments.delete(isarId);
    });
  }

  /// Create a new equipment record and insert it.
  Future<Equipment> createEquipment({
    required String gymId,
    required String name,
    required EquipmentCategory category,
    required String brand,
    required String model,
    required TrainingStyle trainingStyle,
    required int quantity,
    required EquipmentCondition condition,
    DateTime? purchaseDate,
    double? value,
    bool? isPair,
    bool? isEstimate,
    String? serialNumber,
    String? maintenanceNotes,
  }) async {
    final equipment = Equipment(
      gymId: gymId,
      name: name,
      category: category,
      brand: brand,
      model: model,
      trainingStyle: trainingStyle,
      quantity: quantity,
      condition: condition,
      purchaseDate: purchaseDate,
      value: value,
      isPair: isPair,
      isEstimate: isEstimate,
      serialNumber: serialNumber,
      maintenanceNotes: maintenanceNotes,
    );
    await upsert(equipment);
    return equipment;
  }

  /// Update an existing equipment record by Isar id.
  Future<Equipment?> updateEquipment({
    required int id,
    String? name,
    EquipmentCategory? category,
    String? brand,
    String? model,
    TrainingStyle? trainingStyle,
    int? quantity,
    EquipmentCondition? condition,
    String? equipmentId,
    DateTime? purchaseDate,
    double? value,
    bool? isPair,
    bool? isEstimate,
    String? serialNumber,
    String? maintenanceNotes,
  }) async {
    final isar = IsarService.isar;
    final equipment = await isar.equipments.get(id);
    if (equipment == null) return null;
    if (name != null) equipment.name = name;
    if (category != null) equipment.category = category;
    if (brand != null) equipment.brand = brand;
    if (model != null) equipment.model = model;
    if (trainingStyle != null) equipment.trainingStyle = trainingStyle;
    if (quantity != null) equipment.quantity = quantity;
    if (condition != null) equipment.condition = condition;
    if (purchaseDate != null) equipment.purchaseDate = purchaseDate;
    if (value != null) equipment.value = value;
    if (isPair != null) equipment.isPair = isPair;
    if (isEstimate != null) equipment.isEstimate = isEstimate;
    if (serialNumber != null) equipment.serialNumber = serialNumber;
    if (maintenanceNotes != null) equipment.maintenanceNotes = maintenanceNotes;
    await upsert(equipment);
    return equipment;
  }

  /// Delete an equipment record by Isar id and return the deleted equipment.
  Future<Equipment?> deleteEquipment(int id) async {
    final isar = IsarService.isar;
    final equipment = await isar.equipments.get(id);
    if (equipment == null) return null;
    await isar.writeTxn(() async {
      await isar.equipments.delete(id);
    });
    return equipment;
  }

  // -------------------- Lookups ---------------------------------------------

  /// Get by Isar id.
  Future<Equipment?> getByIsarId(int isarId) async {
    final isar = IsarService.isar;
    return isar.equipments.get(isarId);
  }


  // -------------------- List (with search/filter/sort) -----------------------

  /// Core list for a single gym with optional text search, filters, and sorting.
  ///
  /// - `search` matches against name/brand/model (case-insensitive).
  /// - `category` and `condition` map to your indexed fields.
  /// - Sorting is done in Dart to avoid generator-version mismatches.
  Future<List<Equipment>> getAllForGym(
    String gymId, {
    String? search,
    EquipmentCategory? category,
    EquipmentCondition? condition,
    EquipmentSort sort = EquipmentSort.nameAsc,
  }) async {
    final isar = IsarService.isar;

    // Base query leveraging your indexed fields
  var items = await isar.equipments
    .filter()
    .gymIdEqualTo(gymId)
    .optional(category != null, (q) => q.categoryEqualTo(category!))
    .optional(condition != null, (q) => q.conditionEqualTo(condition!))
    .findAll();

    // Local, case-insensitive text search over name/brand/model
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      items = items.where((e) {
        final name = (e.name).toLowerCase();
        final brand = (e.brand).toLowerCase();
        final model = (e.model).toLowerCase();
        return name.contains(q) || brand.contains(q) || model.contains(q);
      }).toList();
    }

    // Sorting (null-safe helpers)
    int cmpDate(DateTime? a, DateTime? b) {
      final aa = a ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bb = b ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aa.compareTo(bb);
    }

    switch (sort) {
      case EquipmentSort.nameAsc:
        items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case EquipmentSort.nameDesc:
        items.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case EquipmentSort.newestPurchase:
        items.sort((a, b) => cmpDate(b.purchaseDate, a.purchaseDate));
        break;
      case EquipmentSort.oldestPurchase:
        items.sort((a, b) => cmpDate(a.purchaseDate, b.purchaseDate));
        break;
      case EquipmentSort.valueHighLow:
        items.sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
        break;
      case EquipmentSort.valueLowHigh:
        items.sort((a, b) => (a.value ?? 0).compareTo(b.value ?? 0));
        break;
    }

    return items;
  }

  // -------------------- Stats ------------------------------------------------

  /// Count items in a gym (for dashboard/pie charts).
  Future<int> countForGym(String gymId) async {
    final isar = IsarService.isar;
    return isar.equipments.filter().gymIdEqualTo(gymId).count();
    // If you later scope by userId too, add that here.
  }
}
