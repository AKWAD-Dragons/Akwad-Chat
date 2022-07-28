import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:json_annotation/json_annotation.dart';

import '../FirebaseChatConfigs.dart';
import 'ChatAttachment.dart';
import 'Message.dart';
import 'Participant.dart';

part '../SendTask.dart';
part 'Room.g.dart';

@JsonSerializable()
class Room {
  String id;
  String name;
  String image;
  List<Participant> participants;
  List<Message> messages;
  @JsonKey(name: "meta_data")
  LinkedHashMap<String, dynamic> metaData;
  @JsonKey(name: "last_message")
  Message lastMessage;
  @JsonKey(name: "last_message_index")
  int lastMessageIndex;

  @JsonKey(ignore: true)
  DatabaseReference _dbr = FirebaseDatabase.instance.reference();

  @JsonKey(ignore: true)
  FirebaseChatConfigs _configs = FirebaseChatConfigs.instance;

  @JsonKey(ignore: true)
  LinkedHashMap<String, dynamic> userRoomData;
  @JsonKey(ignore: true)
  bool _ignoredFirstMessagesOnValue = false;

  Room(this.name, this.image, this.participants, this.messages, this.metaData,
      this.userRoomData, this.lastMessage, this.lastMessageIndex);

  //gets room name if it's not null
  //if null it concatenate participants names using a comma
  String get roomName {
    if (name != null) {
      return name;
    }
    String makeName = "";
    int length = participants.length > 4 ? 4 : participants.length;
    String endText = participants.length > 4 ? ", ..." : "";
    for (int i = 0; i < length; i++) {
      if (participants[i].id == FirebaseChatConfigs.instance.myParticipantID) {
        continue;
      }
      makeName += participants[i].name;
      if (i < participants.length - 1) {
        makeName += ', ';
      }
    }
    return makeName + endText;
  }

  //current room link in RTDB
  String get roomLink => _configs.roomsLink + "/$id";

  //current room messages link in RTDB
  String get messagesLink => _configs.messagesLink + "/$id";

  //listen to Room updates
  Stream get getRoomListener async* {
    await _setUserRoomData();
    await for (Event event in _dbr.child(roomLink).onValue) {
      Room room = parseRoomFromSnapshotValue(event.snapshot?.value ?? null);
      _setThisFromRoom(room);
      yield null;
    }
  }

  //get room data without listening
  Future<Room> getRoom() async {
    DataSnapshot snapshot = await _dbr.child(roomLink).once();
    await _setUserRoomData();
    Room room = parseRoomFromSnapshotValue(snapshot?.value ?? null);
    _setThisFromRoom(room);
    return this;
  }

  //get unread messages count
  int get unreadMessagesCount {
    Participant myParticipant = participants.firstWhere(
        (p) => p.id == FirebaseChatConfigs.instance.myParticipantID);
    if (myParticipant == null) {
      return 0;
    }
    return (lastMessageIndex ?? 0) - (myParticipant.lastSeenMessageIndex ?? 0);
  }

  Future<void> _setUserRoomData([bool force = false]) async {
    if (userRoomData != null && !force) return;
    DataSnapshot snapshot = await _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID + "/rooms")
        .child(id)
        .child('/data')
        .once();
    userRoomData = Map<String, dynamic>.from(snapshot?.value ?? {});
  }

  //copies room object data into current room
  _setThisFromRoom(Room room) {
    this.metaData = room.metaData;
    this.participants = room.participants;
    this.image = room.image;
    this.name = room.name;
    this.lastMessage = room.lastMessage;
    this.lastMessageIndex = room.lastMessageIndex;
  }

  Future<List<Message>> getMessages() async {
    await _setUserRoomData();
    DataSnapshot snapshot = await _dbr.child(messagesLink).once();
    List<Message> messages = _parseMessagesFromSnapshotValue(snapshot.value);
    return messages;
  }

  //get messages listener
  Stream<Message> get getMessagesListener async* {
    await _setUserRoomData();
    await for (Event event in _dbr.child(messagesLink).onValue) {
      if (!_ignoredFirstMessagesOnValue) {
        _ignoredFirstMessagesOnValue = true;
        continue;
      }
      List<Message> messages =
          _parseMessagesFromSnapshotValue(event.snapshot?.value ?? null);
      lastMessage = messages.last;
      yield lastMessage;
    }
  }

  //TODO::make Lobby use this to parse each single room
  //parse room using snapshot value
  Room parseRoomFromSnapshotValue(dynamic snapshotValue) {
    if (snapshotValue == null) return null;
    LinkedHashMap<String, dynamic> roomJson =
        LinkedHashMap<String, dynamic>.from(snapshotValue);
    if (roomJson.containsKey("meta_data")) {
      roomJson['meta_data'] =
          LinkedHashMap<String, dynamic>.from(roomJson["meta_data"]);
    }
    if (roomJson.containsKey("participants")) {
      roomJson['participants'] = roomJson["participants"].keys.map((key) {
        LinkedHashMap<String, dynamic> map =
            LinkedHashMap<String, dynamic>.from(roomJson["participants"][key]);
        map["id"] = key;
        return map;
      }).toList();
    }
    if (roomJson.containsKey("last_message")) {
      var messageMap =
          LinkedHashMap<String, dynamic>.from(roomJson["last_message"]);
      if (messageMap.containsKey("attachments")) {
        messageMap['attachments'] = _buildMessageAttachmentJson(messageMap);
      }
      roomJson["last_message"] = messageMap;
    }
    Room room = Room.fromJson(roomJson);
    return room;
  }

  List<Message> _parseMessagesFromSnapshotValue(dynamic snapShotValue) {
    if (snapShotValue == null) {
      return [];
    }
    String deletedTo;
    if (userRoomData.containsKey("deleted_to")) {
      deletedTo = userRoomData["deleted_to"];
    }
    List<Message> messageList = [];
    for (String key in snapShotValue.keys) {
      if (deletedTo != null && key.compareTo(deletedTo) <= 0) {
        continue;
      }
      if (snapShotValue[key].containsKey("attachments")) {
        snapShotValue[key]['attachments'] =
            _buildMessageAttachmentJson(snapShotValue[key]);
      }
      snapShotValue[key]['id'] = key;
      Message message = _parseMessageFromSnapshotValue(snapShotValue[key]);
      messageList.add(message);
    }
    //sort messages by id
    messageList.sort((a, b) => a.id.compareTo(b.id));
    return messageList;
  }

  Message _parseMessageFromSnapshotValue(dynamic snapShotValue) {
    if (snapShotValue == null) return null;
    if (snapShotValue.containsKey("attachments")) {
      snapShotValue['attachments'] = _buildMessageAttachmentJson(snapShotValue);
    }
    Message message =
        Message.fromJson(LinkedHashMap<String, dynamic>.from(snapShotValue));
    return message;
  }

  List<LinkedHashMap<String, dynamic>> _buildMessageAttachmentJson(
      dynamic messageMap) {
    return List<LinkedHashMap<String, dynamic>>.from(messageMap["attachments"]
        .map((value) => LinkedHashMap<String, dynamic>.from(value))
        .toList());
  }

  //TODO::Allow user to mute a selected room
  Stream<List<Message>> mute() {}

  //Sends a message that may contains text and/or attachments
  //Returns a SendMessageTask that could be used to track attachments upload progress
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

  //assign each attachment to a SingleUploadTask
  //returns a map of {attachment_key:_SingleUploadTask}
  Map<String, _SingleUploadTask> _createUploadAttachmentsTasks(
      List<ChatAttachment> attachments) {
    Map<String, _SingleUploadTask> uploadTasks = {};
    attachments.forEach((ChatAttachment attachment) {
      String path = "$id/${DateTime.now().millisecondsSinceEpoch}";
      _SingleUploadTask singleTask = _SingleUploadTask._(attachment, path);

      //gives current timestamp as a key if no key passed to attachment
      uploadTasks[attachment.key ?? DateTime.now().millisecondsSinceEpoch] =
          singleTask;
    });
    return uploadTasks;
  }

  bool deleteAllMessages() {
    if (lastMessage == null) return false;
    _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID + "/rooms")
        .child(id)
        .child('/data')
        .update({'deleted_to': lastMessage.id}).then(
            (value) => _setUserRoomData(true));
    return true;
  }

  //TODO::[OPTIMIZATION]check if room last seen is the same as the package and ignore sending seen again
  //sets message as seen
  Future<void> markAsRead() async {
    if (lastMessage == null ||
        lastMessage.id == null ||
        lastMessageIndex == null) {
      return;
    }
    await _dbr
        .child(roomLink + "/participants/${_configs.myParticipantID}")
        .update({
      'last_seen_message': lastMessage.id,
      'last_seen_message_index': lastMessageIndex
    });
    await _dbr
        .child(
            _configs.usersLink + "/${_configs.myParticipantID}/rooms/$id/data")
        .update({
      'last_seen_message': lastMessage.id,
      'last_seen_message_index': lastMessageIndex
    });
    _setUserRoomData(true);
  }

  //gets room participants and check last seen message of each participant
  //message is not seen if other participants lastSeenMessage is null or less than message id (using String compare)
  // throws Exception if msg is null
  bool isSeen(Message msg) {
    if (msg == null) {
      throw Exception("Message is null");
    }
    bool isSeen = true;
    for (Participant participant in participants) {
      if (participant.id == msg.user_id) continue;
      if (participant.lastSeenMessage == null) {
        isSeen = false;
        break;
      }
      if ((participant.lastSeenMessage).compareTo(msg.id) < 0) {
        isSeen = false;
        break;
      }
    }
    return isSeen;
  }

  factory Room.fromJson(LinkedHashMap<String, dynamic> json) =>
      _$RoomFromJson(json);

  LinkedHashMap<String, dynamic> toJson() => _$RoomToJson(this);
}
