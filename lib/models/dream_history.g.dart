// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dream_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DreamHistoryAdapter extends TypeAdapter<DreamHistory> {
  @override
  final int typeId = 0;

  @override
  DreamHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DreamHistory(
      dream: fields[0] as String,
      interpretation: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DreamHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dream)
      ..writeByte(1)
      ..write(obj.interpretation)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
