// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    json['text'] as String,
    (json['seenBy'] as List)?.map((e) => e as String)?.toList(),
    json['time'] == null ? null : DateTime.parse(json['time'] as String),
  )..id = json['id'] as String;
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'seenBy': instance.seenBy,
      'time': instance.time?.toIso8601String(),
    };
