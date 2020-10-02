// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    text: json['text'] as String,
    attachments: (json['attachments'] as List)
        ?.map((e) => e == null
            ? null
            : ChatAttachment.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )
    ..id = json['id'] as String
    ..time = Message.dateFromMilliSec(json['time']);
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'time': instance.time?.toIso8601String(),
      'attachments': instance.attachments?.map((e) => e?.toJson())?.toList(),
    };
