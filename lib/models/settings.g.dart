// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsRecordAdapter extends TypeAdapter<SettingsRecord> {
  @override
  final int typeId = 3;

  @override
  SettingsRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsRecord(
      userName: fields[0] as String,
      monthlyBudget: fields[1] as double,
      monthlySalary: fields[2] as double,
      darkMode: fields[3] as bool,
      remindersEnabled: fields[4] as bool,
      reminderMinutesSinceMidnight: fields[5] as int,
      pinLockEnabled: fields[6] as bool,
      onboardingComplete: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.monthlyBudget)
      ..writeByte(2)
      ..write(obj.monthlySalary)
      ..writeByte(3)
      ..write(obj.darkMode)
      ..writeByte(4)
      ..write(obj.remindersEnabled)
      ..writeByte(5)
      ..write(obj.reminderMinutesSinceMidnight)
      ..writeByte(6)
      ..write(obj.pinLockEnabled)
      ..writeByte(7)
      ..write(obj.onboardingComplete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
