import 'package:isar/isar.dart';
import '../src/data/repositories/equipment_repository.dart';
import '../src/models/equipment_model.dart';
import 'ownership_context.dart';

/// Service for CRUD operations on equipment in Isar DB.
class EquipmentService {
  EquipmentService(Isar isar, {OwnershipContext? ownershipContext})
    : _repository = EquipmentRepository(
        isar: isar,
        ownershipContext: ownershipContext,
      );

  final EquipmentRepository _repository;

  Future<void> addEquipment(Equipment equipment) async {
    await _repository.upsert(equipment);
  }

  Future<List<Equipment>> getAllEquipment() async {
    return _repository.getAllForCurrentUser();
  }

  Future<void> updateEquipment(Equipment equipment) async {
    await _repository.updateEquipment(
      id: equipment.id,
      name: equipment.name,
      imageId: equipment.imageId,
      category: equipment.category,
      brand: equipment.brand,
      model: equipment.model,
      trainingStyle: equipment.trainingStyle,
      quantity: equipment.quantity,
      condition: equipment.condition,
      purchaseDate: equipment.purchaseDate,
      value: equipment.value,
      maintenanceNotes: equipment.maintenanceNotes,
    );
  }

  Future<void> deleteEquipment(int id) async {
    await _repository.deleteByIsarId(id);
  }
}
