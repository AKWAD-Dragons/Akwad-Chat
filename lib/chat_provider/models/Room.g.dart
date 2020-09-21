// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) {
  return Room(
    json['id'] as String,
    Room.getParticipants(json['participants']),
    (json['messages'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['lastMassage'] == null
        ? null
        : Message.fromJson(json['lastMassage'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'messages': instance.messages,
      'lastMassage': instance.lastMassage,
    };
