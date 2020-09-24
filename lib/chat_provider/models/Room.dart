import 'package:akwad_chat/chat_provider/models/ChatAttachment.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../FirebaseChatConfigs.dart';
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
      roomJson['participants'] = roomJson["participants"]
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

  SendMessageTask send(Message msg) {
    if (msg.attachments?.isNotEmpty ?? false) {
      SendMessageTask sendMessageTask =
          SendMessageTask._(_createUploadAttachmentsTasks(msg.attachments));
      sendMessageTask
          .addOnCompleteListener((List<ChatAttachment> uploadedAttachments) {
        msg.attachments = uploadedAttachments;
        _dbr.child(messagesLink).push().set(msg.toJson());
      });
      sendMessageTask.startAllTasks();
      return sendMessageTask;
    }
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
    await _dbr
        .child(roomLink + "/participants/${_configs.myParticipantID}")
        .set({'last_seen_message': msg.id});
  }

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
