import 'package:firebase_database/firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Message.g.dart';

@JsonSerializable()
class Message {
  String id;
  String text;
  String type;
  bool seen;

  Message(this.id, this.text, this.type, this.seen);

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @JsonKey(ignore: true)
  static DatabaseReference _dbr = FirebaseDatabase.instance.reference();

  void setSeen(String messageLink, bool seen) {
    _dbr.child(messageLink).set({"seen:$seen"});
  }
}
