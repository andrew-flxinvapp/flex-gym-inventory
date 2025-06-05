import 'dart:ffi';

import 'package:hive/hive.dart';

part 'equipment_model.g.dart';

@HiveType(typeId: 7)
class Equipment extends HiveObject {
    @HiveField(0)
    final String gymId;

    @HiveField(1)
    final String name;

    @HiveField(2)
    final String category;

    @HiveField(3)
    final String brand;

    @HiveField(4)
    final String model;

    @HiveField(5)
    final String trainingStyle;

    @HiveField(6)
    final Int qyantity;

    @HiveField(7)
    final Bool? isPair;

    @HiveField(8)
    final String condition;

    @HiveField(9)
    final DateTime? purchaseDate;

    @HiveField(10)
    final Double? value;

    @HiveField(11)
    final Bool? isEstimate;

    @HiveField(12)
    final String? serialNumber;

    @HiveField(13)
    final String? maintenanceNotes;
    
    @HiveField(14)
    final String equipmentId;

    Equipment({
        required this.gymId,
        required this.name,
        required this.category,
        required this.brand,
        required this.model,
        required this.trainingStyle,
        required this.qyantity,
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