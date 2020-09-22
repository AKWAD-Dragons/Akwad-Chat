import 'package:firebase_database/firebase_database.dart';
import '../FirebaseChatConfigs.dart';
import 'Message.dart';
import 'Participant.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:async';

part 'Room.g.dart';

@JsonSerializable()
class Room {
  String id;
  String name;
  String image;
  List<Participant> participants;
  List<Message> messages;
  Map<String, dynamic> metaData;
  Message lastMessage;

  @JsonKey(ignore: true)
  DatabaseReference _dbr = FirebaseDatabase.instance.reference();

  @JsonKey(ignore: true)
  FirebaseChatConfigs _configs = FirebaseChatConfigs.instance;

  Room(this.name, this.image, this.participants, this.messages, this.metaData,
      this.lastMessage);

  String get roomName {
    if (name != null) {
      return name;
    }
    String makeName = "";
    int length = participants.length > 3 ? 3 : participants.length;
    String endText = participants.length > 3 ? ", ..." : "";
    for (int i = 0; i < length; i++) {
      makeName += participants[i].name;
      if (i < participants.length - 1) {
        makeName += ', ';
      }
    }
    return makeName + endText;
  }

  String get roomLink => _configs.roomsLink + "/$id";

  String get messagesLink => _configs.roomsLink + "/$id/messages";

  Stream get getRoomListener async* {
    await for (Event event in _dbr.child(roomLink).onValue) {
      setRoomFromSnapshot(event.snapshot);
      yield null;
    }
  }

  Future<Room> getRoom() async {
    DataSnapshot snapshot = await _dbr.child(roomLink).once();
    setRoomFromSnapshot(snapshot);
    return this;
  }

  Room setRoomFromSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> roomJson = Map<String, dynamic>.from(snapshot.value);
    if(roomJson.containsKey("messages")) {
      roomJson["messages"] = roomJson["messages"]
          .values
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    }
    Room room = Room.fromJson(roomJson);
    this.metaData = room.metaData;
    this.participants = room.participants;
    this.image = room.image;
    this.name = room.name;
    this.messages = room.messages;
    this.lastMessage = null;
    return room;
  }

  Stream<List<Message>> mute() {}

  Future<void> send(Message msg) async {
    //TODO::check for attachments and generate links
    await _dbr.child(messagesLink).push().set(msg.toJson());
  }

  Future<void> setSeen(Message msg, [bool seen = true]) async {
    await _dbr.child(roomLink + "/${msg.id}").set({'seen': seen});
  }

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
