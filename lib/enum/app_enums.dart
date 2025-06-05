import 'package:hive/hive.dart';
part 'app_enums.g.dart';

// lib/enum/app_enums.dart 
// Enum definitions used acrosss the Flex Gym Inventory app.

@HiveType(typeId: 1)
enum UpgradePriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
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

@HiveType(typeId: 2)
enum EquipmentCategory {
  @HiveField(0)
  barbell,
  @HiveField(1)
  dumbbell,
  @HiveField(2)
  machine,
  @HiveField(3)
  cardio,
  @HiveField(4)
  accessory,
  @HiveField(5)
  plate,
  @HiveField(6)
  storage,
  @HiveField(7)
  support,
  @HiveField(8)
  kettlebell,
  @HiveField(9)
  sandbag,
  @HiveField(10)
  log,
  @HiveField(11)
  yolk,
  @HiveField(12)
  sled,
  @HiveField(13)
  stone,
  @HiveField(14)
  rack,
  @HiveField(15)
  bench,
  @HiveField(16)
  platform,
  @HiveField(17)
  plyoBox,
  @HiveField(18)
  mobility,
  @HiveField(19)
  flooring,
  @HiveField(20)
  safety,
  @HiveField(21)
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

@HiveType(typeId: 3)
enum TrainingStyle {
  @HiveField(0)
  general,
  @HiveField(1)
  olympicWeightlifting,
  @HiveField(2)
  powerlifting,
  @HiveField(3)
  strongman,
  @HiveField(4)
  bodybuilding,
  @HiveField(5)
  crossfit,
  @HiveField(6)
  calisthenics,
  @HiveField(7)
  hiit,
  @HiveField(8)
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

@HiveType(typeId: 4)
enum EquipmentCondition {
  @HiveField(0)
  brandNew,
  @HiveField(1)
  excellent,
  @HiveField(2)
  good,
  @HiveField(3)
  fair,
  @HiveField(4)
  damaged,
  @HiveField(5)
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

@HiveType(typeId: 5)
enum FileType {
  @HiveField(0)
  simplePDF,
  @HiveField(1)
  csv,
  @HiveField(2)
  fullPDF
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

@HiveType(typeId: 6)
enum UpgradeType {
  @HiveField(0)
  newItem,
  @HiveField(1)
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