import 'package:hive/hive.dart';
import '../../enum/app_enums.dart';

part 'upgrades_model.g.dart';

@HiveType(typeId: 9)
class Upgrades extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final UpgradeType upgradeType;

  @HiveField(2)
  final EquipmentCategory category;

  @HiveField(3)
  final String brand;

  @HiveField(4)
  final UpgradePriority priority;

  @HiveField(5)
  final String? productUrl;

  @HiveField(6)
  final String? upgradeNotes;

  Upgrades({
    required this.name,
    required this.upgradeType,
    required this.category,
    required this.brand,
    required this.priority,
    this.productUrl,
    this.upgradeNotes,
  });
}