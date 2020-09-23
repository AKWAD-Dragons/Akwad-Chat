import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'ChatAttachment.g.dart';

@JsonSerializable()
class ChatAttachment{
  @JsonKey(ignore: true)
  String key;
  String fileLink;
  @JsonKey(ignore: true)
  File file;
  String type;
  String format;

  ChatAttachment({this.key,this.file,this.type});

  factory ChatAttachment.fromJson(Map<String, dynamic> json) =>
      _$ChatAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$ChatAttachmentToJson(this);
}