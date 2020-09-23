// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) {
  return Room(
    json['name'] as String,
    json['image'] as String,
    (json['participants'] as List)
        ?.map((e) =>
            e == null ? null : Participant.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['messages'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['meta_data'] as Map<String, dynamic>,
    json['last_message'] == null
        ? null
        : Message.fromJson(json['last_message'] as Map<String, dynamic>),
  )..id = json['id'] as String;
}

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'participants': instance.participants,
      'messages': instance.messages,
      'meta_data': instance.metaData,
      'last_message': instance.lastMessage,
    };
