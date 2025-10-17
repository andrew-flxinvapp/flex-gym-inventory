import 'package:isar/isar.dart';

part 'equipment_model.g.dart';

@Collection()
class Equipment {
  Id id = Isar.autoIncrement;

  /// Indexed fields (for filtering, sorting,and scoping)

  @Index() // used to scope equipment to a specific gym
  late String gymId; 

  @Index(caseSensitive: false) // alphabetical sorting, search
  late String name;

  @Index(caseSensitive: false) // category filter
  late String category;

  @Index(caseSensitive: false) // future condition filter
  late String condition;

  @Index() // for date sorting or filtering
  late DateTime? purchaseDate;

  @Index() // for value-based soriting / insurance export
  late double? value;

  /// Non-indexed fields (informational / secondary data)

  late String brand;
  late String model;
  late String trainingStyle;
  late int quantity;
  bool? isPair;
  bool? isEstimate;
  String? serialNumber;
  String? maintenanceNotes;

  // internal reference ID (human-readable like PREFIX-001)
  late String equipmentId;

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
