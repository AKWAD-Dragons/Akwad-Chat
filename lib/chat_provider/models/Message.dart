import 'package:akwad_chat/chat_provider/models/ChatAttachment.dart';
import 'package:json_annotation/json_annotation.dart';

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
