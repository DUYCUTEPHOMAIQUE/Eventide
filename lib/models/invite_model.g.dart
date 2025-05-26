// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InviteModelAdapter extends TypeAdapter<InviteModel> {
  @override
  final int typeId = 1;

  @override
  InviteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InviteModel(
      cardId: fields[1] as String,
      senderId: fields[2] as String,
      receiverId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InviteModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.receiverId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.sent_at)
      ..writeByte(6)
      ..write(obj.expired_at)
      ..writeByte(7)
      ..write(obj.accepted_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InviteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
