import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';

part 'equipment_model.g.dart';

@Collection()
class Equipment {
  Id id = Isar.autoIncrement;

  @Index()
  late String gymId;

  @Index(caseSensitive: false)
  @Enumerated(EnumType.name)
  late EquipmentCategory category;

  @Index(caseSensitive: false)
  late String name;

  @Index(caseSensitive: false)
  @Enumerated(EnumType.name)
  late EquipmentCondition condition;

  @Index()
  late DateTime? purchaseDate;

  @Index()
  late double? value;

  @Index()
  late String brand;

  @Index()
  @Enumerated(EnumType.name)
  late TrainingStyle trainingStyle;

  late String model;
  late int quantity;
  bool? isPair;
  bool? isEstimate;
  String? serialNumber;
  String? maintenanceNotes;

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
  });

  int? get age {
    if (purchaseDate == null) return null;
    final now = DateTime.now();
    int years = now.year - purchaseDate!.year;
    if (now.month < purchaseDate!.month || (now.month == purchaseDate!.month && now.day < purchaseDate!.day)) {
      years--;
    }
    return years;
  }
}
