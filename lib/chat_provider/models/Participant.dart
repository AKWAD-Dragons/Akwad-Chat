import 'package:json_annotation/json_annotation.dart';

part 'Participant.g.dart';

@JsonSerializable()
class Participant{
  String id;
  String name;
  List<String> permissons;
  Participant(this.id,this.name,this.permissons);

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}