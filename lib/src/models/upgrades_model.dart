import '../../enum/app_enums.dart';

class Upgrades {
  final String name;
  final UpgradeType upgradeType;
  final EquipmentCategory category;
  final String brand;
  final UpgradePriority priority;
  final String? productUrl;
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

  factory Upgrades.fromMap(Map<String, dynamic> map) {
    return Upgrades(
      name: map['name'],
      upgradeType: UpgradeType.values.firstWhere((e) => e.toString() == 'UpgradeType.' + map['upgradeType']),
      category: EquipmentCategory.values.firstWhere((e) => e.toString() == 'EquipmentCategory.' + map['category']),
      brand: map['brand'],
      priority: UpgradePriority.values.firstWhere((e) => e.toString() == 'UpgradePriority.' + map['priority']),
      productUrl: map['productUrl'],
      upgradeNotes: map['upgradeNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'upgradeType': upgradeType.name,
      'category': category.name,
      'brand': brand,
      'priority': priority.name,
      'productUrl': productUrl,
      'upgradeNotes': upgradeNotes,
    };
  }
}