// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipmentAdapter extends TypeAdapter<Equipment> {
  @override
  final int typeId = 7;

  @override
  Equipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Equipment(
      gymId: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      brand: fields[3] as String,
      model: fields[4] as String,
      trainingStyle: fields[5] as String,
      qyantity: fields[6] as Int,
      isPair: fields[7] as Bool?,
      condition: fields[8] as String,
      purchaseDate: fields[9] as DateTime?,
      value: fields[10] as Double?,
      isEstimate: fields[11] as Bool?,
      serialNumber: fields[12] as String?,
      maintenanceNotes: fields[13] as String?,
      equipmentId: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Equipment obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.gymId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.trainingStyle)
      ..writeByte(6)
      ..write(obj.qyantity)
      ..writeByte(7)
      ..write(obj.isPair)
      ..writeByte(8)
      ..write(obj.condition)
      ..writeByte(9)
      ..write(obj.purchaseDate)
      ..writeByte(10)
      ..write(obj.value)
      ..writeByte(11)
      ..write(obj.isEstimate)
      ..writeByte(12)
      ..write(obj.serialNumber)
      ..writeByte(13)
      ..write(obj.maintenanceNotes)
      ..writeByte(14)
      ..write(obj.equipmentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
