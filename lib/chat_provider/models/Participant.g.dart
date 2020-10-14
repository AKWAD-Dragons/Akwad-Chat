// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) {
  return Participant(
    json['id'] as String,
    json['name'] as String,
    (json['permissions'] as List)?.map((e) => e as String)?.toList(),
  )
    ..lastSeenMessage = json['last_seen_message'] as String
    ..meta_data = json['meta_data']
    ..rooms = (json['rooms'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'meta_data': instance.meta_data,
      'last_seen_message': instance.lastSeenMessage,
      'rooms': instance.rooms,
      'permissions': instance.permissions,
    };
