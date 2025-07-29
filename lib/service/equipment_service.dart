import 'package:isar/isar.dart';
import '../src/models/equipment_model.dart';

/// Service for CRUD operations on equipment in Isar DB.
class EquipmentService {
  final Isar isar;
  EquipmentService(this.isar);

  Future<void> addEquipment(Equipment equipment) async {
    await isar.writeTxn(() async {
      await isar.equipments.put(equipment);
    });
  }

  Future<List<Equipment>> getAllEquipment() async {
    return await isar.equipments.where().findAll();
  }

  Future<void> updateEquipment(Equipment equipment) async {
    await isar.writeTxn(() async {
      await isar.equipments.put(equipment);
    });
  }

  Future<void> deleteEquipment(int id) async {
    await isar.writeTxn(() async {
      await isar.equipments.delete(id);
    });
  }
}
