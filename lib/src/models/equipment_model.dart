
class Equipment {
  final String gymId;
  final String name;
  final String category;
  final String brand;
  final String model;
  final String trainingStyle;
  final int quantity;
  final bool? isPair;
  final String condition;
  final DateTime? purchaseDate;
  final double? value;
  final bool? isEstimate;
  final String? serialNumber;
  final String? maintenanceNotes;
  final String equipmentId;

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

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      gymId: map['gymId'],
      name: map['name'],
      category: map['category'],
      brand: map['brand'],
      model: map['model'],
      trainingStyle: map['trainingStyle'],
      quantity: map['quantity'],
      isPair: map['isPair'],
      condition: map['condition'],
      purchaseDate: map['purchaseDate'] != null ? DateTime.parse(map['purchaseDate']) : null,
      value: map['value']?.toDouble(),
      isEstimate: map['isEstimate'],
      serialNumber: map['serialNumber'],
      maintenanceNotes: map['maintenanceNotes'],
      equipmentId: map['equipmentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gymId': gymId,
      'name': name,
      'category': category,
      'brand': brand,
      'model': model,
      'trainingStyle': trainingStyle,
      'quantity': quantity,
      'isPair': isPair,
      'condition': condition,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'value': value,
      'isEstimate': isEstimate,
      'serialNumber': serialNumber,
      'maintenanceNotes': maintenanceNotes,
      'equipmentId': equipmentId,
    };
  }
}