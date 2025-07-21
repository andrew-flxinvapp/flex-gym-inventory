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
  weight,
  implement,
  machine,
  storage,
  rig,
  support,
  safety,
  other,
}

extension EquipmentCategoryLabel on EquipmentCategory {
  String get label {
    switch (this) {
      case EquipmentCategory.weight:
        return 'Weight';
      case EquipmentCategory.implement:
        return 'Implement';
      case EquipmentCategory.machine:
        return 'Machine';
      case EquipmentCategory.storage:
        return 'Storage';
      case EquipmentCategory.rig:
        return 'Rig';
      case EquipmentCategory.support:
        return 'Support';
      case EquipmentCategory.safety:
        return 'Safety';
      case EquipmentCategory.other:
        return 'Other';
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