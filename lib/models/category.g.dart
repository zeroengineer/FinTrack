// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryRecordAdapter extends TypeAdapter<CategoryRecord> {
  @override
  final int typeId = 1;

  @override
  CategoryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryRecord(
      id: fields[0] as String,
      name: fields[1] as String,
      kind: fields[2] as TxnKind,
      iconName: fields[3] as String,
      colorHex: fields[4] as String,
      isCustom: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.kind)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.colorHex)
      ..writeByte(5)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
