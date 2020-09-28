import 'package:json_annotation/json_annotation.dart';

import 'ChatAttachment.dart';

part 'Message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  String id;
  String text;
  DateTime time;
  List<ChatAttachment> attachments;

  Message({this.text,this.attachments});


  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
