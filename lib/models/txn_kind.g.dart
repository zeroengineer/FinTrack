// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txn_kind.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TxnKindAdapter extends TypeAdapter<TxnKind> {
  @override
  final int typeId = 2;

  @override
  TxnKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TxnKind.expense;
      case 1:
        return TxnKind.income;
      default:
        return TxnKind.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TxnKind obj) {
    switch (obj) {
      case TxnKind.expense:
        writer.writeByte(0);
        break;
      case TxnKind.income:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TxnKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
