// lib/enum/app_enums.dart 
// Enum definitions used across the Flex Gym Inventory app.

// Upgrade priorities for planned upgrades
enum UpgradePriority {
  low,
  medium,
  high,
}

extension UpgradePriorityLabel on UpgradePriority {
  String get label {
    switch (this) {
      case UpgradePriority.low:
        return 'Low';
      case UpgradePriority.medium:
        return 'Medium';
      case UpgradePriority.high:
        return 'High';
    }
  }
}

// Equipment categories for gym inventory
enum EquipmentCategory {
  barbell,
  dumbbell,
  machine,
  cardio,
  accessory,
  plate,
  storage,
  support,
  kettlebell,
  sandbag,
  log,
  yolk,
  sled,
  stone,
  rack,
  bench,
  platform,
  plyoBox,
  mobility,
  flooring,
  safety,
  tracking,
}

extension EquipmentCategoryLabel on EquipmentCategory {
  String get label {
    switch (this) {
      case EquipmentCategory.barbell:
        return 'Barbell';
      case EquipmentCategory.dumbbell:
        return 'Dumbbell';
      case EquipmentCategory.machine:
        return 'Machine';
      case EquipmentCategory.cardio:
        return 'Cardio';
      case EquipmentCategory.accessory:
        return 'Accessory';
      case EquipmentCategory.plate:
        return 'Plate';
      case EquipmentCategory.storage:
        return 'Storage';
      case EquipmentCategory.support:
        return 'Support';
      case EquipmentCategory.kettlebell:
        return 'Kettlebell';
      case EquipmentCategory.sandbag:
        return 'Sandbag';
      case EquipmentCategory.log:
        return 'Log';
      case EquipmentCategory.yolk:
        return 'Yolk';
      case EquipmentCategory.sled:
        return 'Sled';
      case EquipmentCategory.stone:
        return 'Stone';
      case EquipmentCategory.rack:
        return 'Rack';
      case EquipmentCategory.bench:
        return 'Bench';
      case EquipmentCategory.platform:
        return 'Platform';
      case EquipmentCategory.plyoBox:
        return 'Plyo Box';
      case EquipmentCategory.mobility:
        return 'Mobility';
      case EquipmentCategory.flooring:
        return 'Flooring';
      case EquipmentCategory.safety:
        return 'Safety';
      case EquipmentCategory.tracking:
        return 'Tracking';
    }
  }
}

extension EquipmentCategoryID on EquipmentCategory {
  String get idPrefix {
    switch (this) {
      case EquipmentCategory.barbell:
        return 'BAR';
      case EquipmentCategory.dumbbell:
        return 'DMB';
      case EquipmentCategory.machine:
        return 'MAC';
      case EquipmentCategory.cardio:
        return 'CARD';
      case EquipmentCategory.accessory:
        return 'ACC';
      case EquipmentCategory.plate:
        return 'PLT';
      case EquipmentCategory.storage:
        return 'STOR';
      case EquipmentCategory.support:
        return 'SUP';
      case EquipmentCategory.kettlebell:
        return 'KTB';
      case EquipmentCategory.sandbag:
        return 'SAND';
      case EquipmentCategory.log:
        return 'LOG';
      case EquipmentCategory.yolk:
        return 'YLK';
      case EquipmentCategory.sled:
        return 'SLD';
      case EquipmentCategory.stone:
        return 'STN';
      case EquipmentCategory.rack:
        return 'RAC';
      case EquipmentCategory.bench:
        return 'BNC';
      case EquipmentCategory.platform:
        return 'PLAT';
      case EquipmentCategory.plyoBox:
        return 'BOX';
      case EquipmentCategory.mobility:
        return 'MOB';
      case EquipmentCategory.flooring:
        return 'FLOR';
      case EquipmentCategory.safety:
        return 'SAFT';
      case EquipmentCategory.tracking:
        return 'TRK';
    }
  }
}

// Training styles for gym users
enum TrainingStyle {
  general,
  olympicWeightlifting,
  powerlifting,
  strongman,
  bodybuilding,
  crossfit,
  calisthenics,
  hiit,
  circuit,
}

extension TrainingStyleLabel on TrainingStyle {
  String get label {
    switch (this) {
      case TrainingStyle.general:
        return 'General';
      case TrainingStyle.olympicWeightlifting:
        return 'Olympic Weightlifting';
      case TrainingStyle.powerlifting:
        return 'Powerlifting';
      case TrainingStyle.strongman:
        return 'Strongman';
      case TrainingStyle.bodybuilding:
        return 'Bodybuilding';
      case TrainingStyle.crossfit:
        return 'CrossFit';
      case TrainingStyle.calisthenics:
        return 'Calisthenics';
      case TrainingStyle.hiit:
        return 'HIIT';
      case TrainingStyle.circuit:
        return 'Circuit';
    }
  }
}

// Equipment condition states
enum EquipmentCondition {
  brandNew,
  excellent,
  good,
  fair,
  damaged,
  retired,
}

extension EquipmentConditionLabel on EquipmentCondition {
  String get label {
    switch (this) {
      case EquipmentCondition.brandNew:
        return 'Brand New';
      case EquipmentCondition.excellent:
        return 'Excellent';
      case EquipmentCondition.good:
        return 'Good';
      case EquipmentCondition.fair:
        return 'Fair';
      case EquipmentCondition.damaged:
        return 'Damaged';
      case EquipmentCondition.retired:
        return 'Retired';
    }
  }
}

// File types for export/import
enum FileType {
  simplePDF,
  csv,
  fullPDF,
}

extension FileTypeLabel on FileType {
  String get label {
    switch (this) {
      case FileType.simplePDF:
        return 'Simple PDF';
      case FileType.csv:
        return 'CSV';
      case FileType.fullPDF:
        return 'Full PDF';
    }
  }
}

// Upgrade types for planned upgrades
enum UpgradeType {
  newItem,
  replacement,
}

extension UpgradeTypeLabel on UpgradeType {
  String get label {
    switch (this) {
      case UpgradeType.newItem:
        return 'New Item';
      case UpgradeType.replacement:
        return 'Replacement';
    }
  }
}