// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalsAdapter extends TypeAdapter<Personals> {
  @override
  final int typeId = 1;

  @override
  Personals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Personals(
      fields[1] as String,
      email: (fields[4] as List)?.cast<String>(),
      image: fields[0] as String,
      lastName: fields[2] as String,
      phones: (fields[3] as List)?.cast<String>(),
      birthday: fields[5] as String,
      gender: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Personals obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.image)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.phones)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.birthday)
      ..writeByte(6)
      ..write(obj.gender);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
