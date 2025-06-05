// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrades_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpgradesAdapter extends TypeAdapter<Upgrades> {
  @override
  final int typeId = 9;

  @override
  Upgrades read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Upgrades(
      name: fields[0] as String,
      upgradeType: fields[1] as UpgradeType,
      category: fields[2] as EquipmentCategory,
      brand: fields[3] as String,
      priority: fields[4] as UpgradePriority,
      productUrl: fields[5] as String?,
      upgradeNotes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Upgrades obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.upgradeType)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.productUrl)
      ..writeByte(6)
      ..write(obj.upgradeNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpgradesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
