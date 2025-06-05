// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GymAdapter extends TypeAdapter<Gym> {
  @override
  final int typeId = 8;

  @override
  Gym read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gym(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String?,
      gymNotes: fields[3] as String?,
      createdDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Gym obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.gymNotes)
      ..writeByte(4)
      ..write(obj.createdDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
