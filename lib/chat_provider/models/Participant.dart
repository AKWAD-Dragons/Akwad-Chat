import 'package:json_annotation/json_annotation.dart';

part 'Participant.g.dart';

//Chat Participant data
@JsonSerializable()
class Participant {
  String id;
  String name;
  Map meta_data;
  @JsonKey(name: "last_seen_message")
  String lastSeenMessage;
  @JsonKey(name: "last_seen_message_index")
  int lastSeenMessageIndex;
  List<String> rooms;
  List<String> permissions;

  Participant(this.id, this.name, this.permissions);

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}
