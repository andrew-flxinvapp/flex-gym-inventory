// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpgradePriorityAdapter extends TypeAdapter<UpgradePriority> {
  @override
  final int typeId = 1;

  @override
  UpgradePriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UpgradePriority.low;
      case 1:
        return UpgradePriority.medium;
      case 2:
        return UpgradePriority.high;
      default:
        return UpgradePriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, UpgradePriority obj) {
    switch (obj) {
      case UpgradePriority.low:
        writer.writeByte(0);
        break;
      case UpgradePriority.medium:
        writer.writeByte(1);
        break;
      case UpgradePriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpgradePriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentCategoryAdapter extends TypeAdapter<EquipmentCategory> {
  @override
  final int typeId = 2;

  @override
  EquipmentCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EquipmentCategory.barbell;
      case 1:
        return EquipmentCategory.dumbbell;
      case 2:
        return EquipmentCategory.machine;
      case 3:
        return EquipmentCategory.cardio;
      case 4:
        return EquipmentCategory.accessory;
      case 5:
        return EquipmentCategory.plate;
      case 6:
        return EquipmentCategory.storage;
      case 7:
        return EquipmentCategory.support;
      case 8:
        return EquipmentCategory.kettlebell;
      case 9:
        return EquipmentCategory.sandbag;
      case 10:
        return EquipmentCategory.log;
      case 11:
        return EquipmentCategory.yolk;
      case 12:
        return EquipmentCategory.sled;
      case 13:
        return EquipmentCategory.stone;
      case 14:
        return EquipmentCategory.rack;
      case 15:
        return EquipmentCategory.bench;
      case 16:
        return EquipmentCategory.platform;
      case 17:
        return EquipmentCategory.plyoBox;
      case 18:
        return EquipmentCategory.mobility;
      case 19:
        return EquipmentCategory.flooring;
      case 20:
        return EquipmentCategory.safety;
      case 21:
        return EquipmentCategory.tracking;
      default:
        return EquipmentCategory.barbell;
    }
  }

  @override
  void write(BinaryWriter writer, EquipmentCategory obj) {
    switch (obj) {
      case EquipmentCategory.barbell:
        writer.writeByte(0);
        break;
      case EquipmentCategory.dumbbell:
        writer.writeByte(1);
        break;
      case EquipmentCategory.machine:
        writer.writeByte(2);
        break;
      case EquipmentCategory.cardio:
        writer.writeByte(3);
        break;
      case EquipmentCategory.accessory:
        writer.writeByte(4);
        break;
      case EquipmentCategory.plate:
        writer.writeByte(5);
        break;
      case EquipmentCategory.storage:
        writer.writeByte(6);
        break;
      case EquipmentCategory.support:
        writer.writeByte(7);
        break;
      case EquipmentCategory.kettlebell:
        writer.writeByte(8);
        break;
      case EquipmentCategory.sandbag:
        writer.writeByte(9);
        break;
      case EquipmentCategory.log:
        writer.writeByte(10);
        break;
      case EquipmentCategory.yolk:
        writer.writeByte(11);
        break;
      case EquipmentCategory.sled:
        writer.writeByte(12);
        break;
      case EquipmentCategory.stone:
        writer.writeByte(13);
        break;
      case EquipmentCategory.rack:
        writer.writeByte(14);
        break;
      case EquipmentCategory.bench:
        writer.writeByte(15);
        break;
      case EquipmentCategory.platform:
        writer.writeByte(16);
        break;
      case EquipmentCategory.plyoBox:
        writer.writeByte(17);
        break;
      case EquipmentCategory.mobility:
        writer.writeByte(18);
        break;
      case EquipmentCategory.flooring:
        writer.writeByte(19);
        break;
      case EquipmentCategory.safety:
        writer.writeByte(20);
        break;
      case EquipmentCategory.tracking:
        writer.writeByte(21);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrainingStyleAdapter extends TypeAdapter<TrainingStyle> {
  @override
  final int typeId = 3;

  @override
  TrainingStyle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrainingStyle.general;
      case 1:
        return TrainingStyle.olympicWeightlifting;
      case 2:
        return TrainingStyle.powerlifting;
      case 3:
        return TrainingStyle.strongman;
      case 4:
        return TrainingStyle.bodybuilding;
      case 5:
        return TrainingStyle.crossfit;
      case 6:
        return TrainingStyle.calisthenics;
      case 7:
        return TrainingStyle.hiit;
      case 8:
        return TrainingStyle.circuit;
      default:
        return TrainingStyle.general;
    }
  }

  @override
  void write(BinaryWriter writer, TrainingStyle obj) {
    switch (obj) {
      case TrainingStyle.general:
        writer.writeByte(0);
        break;
      case TrainingStyle.olympicWeightlifting:
        writer.writeByte(1);
        break;
      case TrainingStyle.powerlifting:
        writer.writeByte(2);
        break;
      case TrainingStyle.strongman:
        writer.writeByte(3);
        break;
      case TrainingStyle.bodybuilding:
        writer.writeByte(4);
        break;
      case TrainingStyle.crossfit:
        writer.writeByte(5);
        break;
      case TrainingStyle.calisthenics:
        writer.writeByte(6);
        break;
      case TrainingStyle.hiit:
        writer.writeByte(7);
        break;
      case TrainingStyle.circuit:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentConditionAdapter extends TypeAdapter<EquipmentCondition> {
  @override
  final int typeId = 4;

  @override
  EquipmentCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EquipmentCondition.brandNew;
      case 1:
        return EquipmentCondition.excellent;
      case 2:
        return EquipmentCondition.good;
      case 3:
        return EquipmentCondition.fair;
      case 4:
        return EquipmentCondition.damaged;
      case 5:
        return EquipmentCondition.retired;
      default:
        return EquipmentCondition.brandNew;
    }
  }

  @override
  void write(BinaryWriter writer, EquipmentCondition obj) {
    switch (obj) {
      case EquipmentCondition.brandNew:
        writer.writeByte(0);
        break;
      case EquipmentCondition.excellent:
        writer.writeByte(1);
        break;
      case EquipmentCondition.good:
        writer.writeByte(2);
        break;
      case EquipmentCondition.fair:
        writer.writeByte(3);
        break;
      case EquipmentCondition.damaged:
        writer.writeByte(4);
        break;
      case EquipmentCondition.retired:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileTypeAdapter extends TypeAdapter<FileType> {
  @override
  final int typeId = 5;

  @override
  FileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileType.simplePDF;
      case 1:
        return FileType.csv;
      case 2:
        return FileType.fullPDF;
      default:
        return FileType.simplePDF;
    }
  }

  @override
  void write(BinaryWriter writer, FileType obj) {
    switch (obj) {
      case FileType.simplePDF:
        writer.writeByte(0);
        break;
      case FileType.csv:
        writer.writeByte(1);
        break;
      case FileType.fullPDF:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UpgradeTypeAdapter extends TypeAdapter<UpgradeType> {
  @override
  final int typeId = 6;

  @override
  UpgradeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UpgradeType.newItem;
      case 1:
        return UpgradeType.replacement;
      default:
        return UpgradeType.newItem;
    }
  }

  @override
  void write(BinaryWriter writer, UpgradeType obj) {
    switch (obj) {
      case UpgradeType.newItem:
        writer.writeByte(0);
        break;
      case UpgradeType.replacement:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpgradeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
