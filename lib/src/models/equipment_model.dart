import 'package:isar/isar.dart';

part 'equipment_model.g.dart';

@Collection()
class Equipment {
  Id id = Isar.autoIncrement;
  String gymId;
  String name;
  String category;
  String brand;
  String model;
  String trainingStyle;
  int quantity;
  bool? isPair;
  String condition;
  DateTime? purchaseDate;
  double? value;
  bool? isEstimate;
  String? serialNumber;
  String? maintenanceNotes;
  String equipmentId;

  Equipment({
    required this.gymId,
    required this.name,
    required this.category,
    required this.brand,
    required this.model,
    required this.trainingStyle,
    required this.quantity,
    this.isPair,
    required this.condition,
    this.purchaseDate,
    this.value,
    this.isEstimate,
    this.serialNumber,
    this.maintenanceNotes,
    required this.equipmentId,
  });
}
