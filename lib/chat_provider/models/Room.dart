import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../FirebaseChatConfigs.dart';
import 'ChatAttachment.dart';
import 'Message.dart';
import 'Participant.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:async';

part 'Room.g.dart';

part '../SendTask.dart';

@JsonSerializable()
class Room {
  String id;
  String name;
  String image;
  List<Participant> participants;
  List<Message> messages;
  @JsonKey(name: "meta_data")
  Map<String, dynamic> metaData;
  @JsonKey(name: "last_message")
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
    int length = participants.length > 4 ? 4 : participants.length;
    String endText = participants.length > 4 ? ", ..." : "";
    for (int i = 0; i < length; i++) {
      if(participants[i].id==FirebaseChatConfigs.instance.myParticipantID){
        continue;
      }
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
      parseRoomFromSnapshot(event.snapshot);
      yield null;
    }
  }

  Future<Room> getRoom() async {
    DataSnapshot snapshot = await _dbr.child(roomLink).once();
    parseRoomFromSnapshot(snapshot);
    return this;
  }

  Room parseRoomFromSnapshot(DataSnapshot snapshot) {
    if (snapshot == null || snapshot.value == null) return null;
    Map<String, dynamic> roomJson = Map<String, dynamic>.from(snapshot.value);
    if (roomJson.containsKey("messages")) {
      List messagesJsonList;
      messagesJsonList = roomJson["messages"].keys.map((key) {
        var messageMap = Map<String, dynamic>.from(roomJson["messages"][key]);
        if (messageMap.containsKey("attachments")) {
          List<Map<String, dynamic>> attachments =
              List<Map<String, dynamic>>.from(messageMap["attachments"]
                  .map((value) => Map<String, dynamic>.from(value))
                  .toList());

          messageMap['attachments'] = attachments;
        }
        messageMap['id'] = key;
        return messageMap;
      }).toList();

      messagesJsonList.sort((a, b) {
        return a['id'].compareTo(b['id']);
      });

      roomJson['messages'] = messagesJsonList;
    }
    if (roomJson.containsKey("meta_data")) {
      roomJson['meta_data'] = Map<String, dynamic>.from(roomJson["meta_data"]);
    }
    if (roomJson.containsKey("participants")) {
      roomJson['participants'] = roomJson["participants"].keys.map((key) {
        Map<String, dynamic> map = Map<String, dynamic>.from(roomJson["participants"][key]);
        map["id"] = key;
        return map;
      }).toList();
    }
    if (roomJson.containsKey("last_message")) {
      var messageMap = Map<String, dynamic>.from(roomJson["last_message"]);
      if (messageMap.containsKey("attachments")) {
        List<Map<String, dynamic>> attachments =
            List<Map<String, dynamic>>.from(messageMap["attachments"]
                .map((value) => Map<String, dynamic>.from(value))
                .toList());

        messageMap['attachments'] = attachments;
      }
      roomJson["last_message"] = messageMap;
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

  SendMessageTask send(Message msg) {
    if (msg.attachments?.isNotEmpty ?? false) {
      SendMessageTask sendMessageTask =
          SendMessageTask._(_createUploadAttachmentsTasks(msg.attachments));
      sendMessageTask
          .addOnCompleteListener((List<ChatAttachment> uploadedAttachments) {
        msg.attachments = uploadedAttachments;
        _dbr.child("buffer/$id").push().set(msg.toJson());
      });
      sendMessageTask.startAllTasks();
      return sendMessageTask;
    }
    _dbr.child("buffer/$id").push().set(msg.toJson());
    return SendMessageTask._({"send_task": _SingleUploadTask._(null, null)});
  }

  Map<String, _SingleUploadTask> _createUploadAttachmentsTasks(
      List<ChatAttachment> attachments) {
    Map<String, _SingleUploadTask> uploadTasks = {};
    attachments.forEach((ChatAttachment attachment) {
      String path = "$id/${DateTime.now().millisecondsSinceEpoch}";
      _SingleUploadTask singleTask = _SingleUploadTask._(attachment, path);

      uploadTasks[attachment.key ?? DateTime.now().millisecondsSinceEpoch] =
          singleTask;
    });
    return uploadTasks;
  }

  Future<void> setSeen(Message msg, [bool seen = true]) async {
    if (msg == null) {
      return;
    }
    await _dbr
        .child(roomLink + "/participants/${_configs.myParticipantID}")
        .update({'last_seen_message': msg.id});
  }

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
