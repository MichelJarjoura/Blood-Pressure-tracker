// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bp_reading.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BpReadingAdapter extends TypeAdapter<BpReading> {
  @override
  final int typeId = 0;

  @override
  BpReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BpReading(
      systolic: fields[0] as int,
      diastolic: fields[1] as int,
      pulse: fields[2] as int?,
      timestamp: fields[3] as DateTime,
      note: fields[4] as String?,
      arm: fields[5] as String?,
      bodyPosition: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BpReading obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.systolic)
      ..writeByte(1)
      ..write(obj.diastolic)
      ..writeByte(2)
      ..write(obj.pulse)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.arm)
      ..writeByte(6)
      ..write(obj.bodyPosition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BpReadingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
