import 'dart:async';

import 'package:akwad_chat/chat_provider/chat_configs.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'Message.dart';
import 'Participant.dart';

part 'Room.g.dart';

@JsonSerializable()
class Room {
  String id;
  @JsonKey(fromJson: getParticipants)
  List<Participant> participants;
  List<Message> messages;
  Message lastMassage;

  Room(this.id, this.participants, this.messages, this.lastMassage);

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @JsonKey(ignore: true)
  static getParticipants(json) {
    if (json['meta-data'] == null) return null;
    return (json['meta-data']['participants'] as List)
        ?.map((e) =>
            e == null ? null : Participant.fromJson(e as Map<String, dynamic>))
        ?.toList();
  }

  @JsonKey(ignore: true)
  static BehaviorSubject<List<Room>> roomsBS = BehaviorSubject();
  @JsonKey(ignore: true)
  static DatabaseReference _dbr = FirebaseDatabase.instance.reference();
  @JsonKey(ignore: true)
  static StreamSubscription _roomSub;

  @JsonKey(ignore: true)
  BehaviorSubject<List<Message>> messagesBS = BehaviorSubject();
  @JsonKey(ignore: true)
  StreamSubscription _messageSub;


  static listenToAll(String link) async {
    DataSnapshot snapshot = await _dbr.child(link).once();
    List<Room> rooms = List.of(snapshot.value);
    if (_roomSub != null) {
      _roomSub.cancel();
      _roomSub = null;
    }
    roomsBS.add(rooms);
    _roomSub = _dbr.child(link).onValue.listen((Event event) {
      List<Room> rooms = List.of(event.snapshot.value);
      roomsBS.add(rooms);
    });
    return roomsBS;
  }

  BehaviorSubject<List<Message>> listen() {
    checkConfigs();
    String chatNodeLink = ChatConfigs.instance().chatNodeLink;
    chatNodeLink = "$chatNodeLink/$id/messages";
    if (_messageSub != null) {
      _messageSub.cancel();
      _messageSub = null;
    }
    _messageSub = _dbr.child(chatNodeLink).onValue.listen((event) {
      List<Message> messages = List.of(event.snapshot.value);
      messagesBS.add(messages);
    });
    return messagesBS;
  }

  void checkConfigs() {
    if (ChatConfigs.instance().chatNodeLink == null) {
      throw ("chatNodeLink is null did you forget to call ChatConfig.instance.setConfigs?");
    }
  }
}
