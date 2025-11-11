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

  @Index() // brand filter
  late String brand;

  @Index() // training style filter
  late String trainingStyle; 

  /// Non-indexed fields (informational / secondary data)

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
