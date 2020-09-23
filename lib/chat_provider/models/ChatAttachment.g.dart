// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChatAttachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatAttachment _$ChatAttachmentFromJson(Map<String, dynamic> json) {
  return ChatAttachment(
    type: json['type'] as String,
  )
    ..fileLink = json['fileLink'] as String
    ..format = json['format'] as String;
}

Map<String, dynamic> _$ChatAttachmentToJson(ChatAttachment instance) =>
    <String, dynamic>{
      'fileLink': instance.fileLink,
      'type': instance.type,
      'format': instance.format,
    };
