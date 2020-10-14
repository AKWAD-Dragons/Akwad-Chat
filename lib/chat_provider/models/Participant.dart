import 'package:json_annotation/json_annotation.dart';

part 'Participant.g.dart';

@JsonSerializable()
class Participant {
  String id;
  String name;
  @JsonKey(name: "last_seen_message")
  Map meta_data;
  String lastSeenMessage;
  List<String> rooms;
  List<String> permissions;

  Participant(this.id, this.name, this.permissions);

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}
