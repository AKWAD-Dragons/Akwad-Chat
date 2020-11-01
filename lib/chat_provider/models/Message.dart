import 'package:json_annotation/json_annotation.dart';

import 'ChatAttachment.dart';

part 'Message.g.dart';


//Message Data
@JsonSerializable(explicitToJson: true)
class Message {
  String id;
  String text;
  String user_id;
  @JsonKey(fromJson:dateFromMilliSec)
  DateTime time;
  List<ChatAttachment> attachments;

  Message({this.text,this.attachments});

  //parses timestamp(long) to (DateTime)
  static dateFromMilliSec (val){
    return DateTime.fromMillisecondsSinceEpoch(val);
  }

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
