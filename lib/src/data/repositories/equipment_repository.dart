import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/service/ownership_context.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/service/image_service.dart';

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
  EquipmentRepository({Isar? isar, OwnershipContext? ownershipContext})
    : _isar = isar,
      _ownershipContext = ownershipContext ?? OwnershipContext();

  final Isar? _isar;
  final OwnershipContext _ownershipContext;

  Isar get _database => _isar ?? IsarService.isar;

  Future<bool> _ownsGym(String gymId, String userId) async {
    if (!_ownershipContext.isCurrentUser(userId)) return false;
    final gym =
        await _database.gyms
            .filter()
            .userIdEqualTo(userId)
            .and()
            .gymIdEqualTo(gymId)
            .findFirst();
    return gym != null && _ownershipContext.isCurrentUser(userId);
  }

  Future<bool> _ownsEquipment(Equipment equipment, String userId) =>
      _ownsGym(equipment.gymId, userId);

  // -------------------- Create / Update / Delete -----------------------------

  /// Insert or replace an equipment record.
  Future<void> upsert(Equipment equipment) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) {
      throw StateError('An authenticated user is required to save equipment.');
    }

    await _database.writeTxn(() async {
      final existing = await _database.equipments.get(equipment.id);
      if (existing != null && !await _ownsEquipment(existing, userId)) {
        throw StateError('The equipment does not belong to the current user.');
      }
      if (!await _ownsGym(equipment.gymId, userId)) {
        throw StateError(
          'The selected gym does not belong to the current user.',
        );
      }
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while saving equipment.');
      }
      await _database.equipments.put(equipment);
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while saving equipment.');
      }
    });
  }

  /// Delete by Isar id.
  Future<void> deleteByIsarId(int isarId) async {
    await deleteEquipment(isarId);
  }

  /// Create a new equipment record and insert it.
  Future<Equipment> createEquipment({
    required String gymId,
    required String name,
    String? imageId,
    required EquipmentCategory category,
    required String brand,
    required String model,
    required TrainingStyle trainingStyle,
    required int quantity,
    required EquipmentCondition condition,
    DateTime? purchaseDate,
    double? value,
    String? maintenanceNotes,
    DateTime? createdDate,
  }) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null || !await _ownsGym(gymId, userId)) {
      throw StateError('The selected gym does not belong to the current user.');
    }
    final equipment = Equipment(
      gymId: gymId,
      name: name,
      imageId: imageId,
      category: category,
      brand: brand,
      model: model,
      trainingStyle: trainingStyle,
      quantity: quantity,
      condition: condition,
      createdDate: createdDate ?? DateTime.now(),
      purchaseDate: purchaseDate,
      value: value,
      maintenanceNotes: maintenanceNotes,
    );
    await upsert(equipment);
    return equipment;
  }

  /// Update an existing equipment record by Isar id.
  Future<Equipment?> updateEquipment({
    required int id,
    String? name,
    String? imageId,
    EquipmentCategory? category,
    String? brand,
    String? model,
    TrainingStyle? trainingStyle,
    int? quantity,
    EquipmentCondition? condition,
    DateTime? purchaseDate,
    double? value,
    String? maintenanceNotes,
  }) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;

    return _database.writeTxn(() async {
      final equipment = await _database.equipments.get(id);
      if (equipment == null ||
          !await _ownsEquipment(equipment, userId) ||
          !_ownershipContext.isCurrentUser(userId)) {
        return null;
      }
      if (name != null) equipment.name = name;
      if (category != null) equipment.category = category;
      if (brand != null) equipment.brand = brand;
      if (model != null) equipment.model = model;
      if (trainingStyle != null) equipment.trainingStyle = trainingStyle;
      if (quantity != null) equipment.quantity = quantity;
      if (condition != null) equipment.condition = condition;
      if (purchaseDate != null) equipment.purchaseDate = purchaseDate;
      if (value != null) equipment.value = value;
      if (maintenanceNotes != null) {
        equipment.maintenanceNotes = maintenanceNotes;
      }
      if (imageId != null) equipment.imageId = imageId;
      await _database.equipments.put(equipment);
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while updating equipment.');
      }
      return equipment;
    });
  }

  /// Delete an equipment record by Isar id and return the deleted equipment.
  Future<Equipment?> deleteEquipment(int id) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;

    final deleted = await _database.writeTxn(() async {
      final equipment = await _database.equipments.get(id);
      if (equipment == null ||
          !await _ownsEquipment(equipment, userId) ||
          !_ownershipContext.isCurrentUser(userId)) {
        return null;
      }
      await _database.equipments.delete(id);
      if (!_ownershipContext.isCurrentUser(userId)) {
        throw StateError('Authentication changed while deleting equipment.');
      }
      return equipment;
    });
    if (deleted == null) return null;

    try {
      if (deleted.imageId != null) {
        await ImageService.instance.deleteImage(deleted.imageId!);
      }
    } catch (_) {}

    return deleted;
  }

  // -------------------- Lookups ---------------------------------------------

  /// Get by Isar id.
  Future<Equipment?> getByIsarId(int isarId) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return null;
    final equipment = await _database.equipments.get(isarId);
    if (equipment == null ||
        !await _ownsEquipment(equipment, userId) ||
        !_ownershipContext.isCurrentUser(userId)) {
      return null;
    }
    return equipment;
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
    final userId = _ownershipContext.currentUserId;
    if (userId == null || !await _ownsGym(gymId, userId)) return [];

    // Base query leveraging your indexed fields
    var items =
        await _database.equipments
            .filter()
            .gymIdEqualTo(gymId)
            .optional(category != null, (q) => q.categoryEqualTo(category!))
            .optional(condition != null, (q) => q.conditionEqualTo(condition!))
            .findAll();
    if (!_ownershipContext.isCurrentUser(userId)) return [];

    // Local, case-insensitive text search over name/brand/model
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      items =
          items.where((e) {
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
        items.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case EquipmentSort.nameDesc:
        items.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
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

    return _ownershipContext.isCurrentUser(userId) ? items : [];
  }

  // -------------------- Stats ------------------------------------------------

  /// Count items in a gym (for dashboard/pie charts).
  Future<int> countForGym(String gymId) async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null || !await _ownsGym(gymId, userId)) return 0;
    final count =
        await _database.equipments.filter().gymIdEqualTo(gymId).count();
    return _ownershipContext.isCurrentUser(userId) ? count : 0;
  }

  Future<List<Equipment>> getAllForCurrentUser() async {
    final userId = _ownershipContext.currentUserId;
    if (userId == null) return [];
    final gyms = await _database.gyms.filter().userIdEqualTo(userId).findAll();
    if (!_ownershipContext.isCurrentUser(userId)) return [];
    final equipment = <Equipment>[];
    for (final gym in gyms) {
      equipment.addAll(await getAllForGym(gym.gymId));
      if (!_ownershipContext.isCurrentUser(userId)) return [];
    }
    return equipment;
  }
}
