import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';

import '../FirebaseChatConfigs.dart';
import 'Participant.dart';
import 'Room.dart';

class Lobby {
  FirebaseChatConfigs _configs;
  DatabaseReference _dbr;
  Participant _myParticipant;
  List<Room> rooms;
  BehaviorSubject<List<Room>> _roomsSubject = BehaviorSubject<List<Room>>();

  Lobby() {
    _configs = FirebaseChatConfigs.instance;
    _dbr = FirebaseDatabase.instance.reference();
  }

  Stream<List<Room>> getLobbyListener() {
    _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID + "/rooms")
        .onValue
        .listen((event) {
      rooms = setRoomsFromSnapshot(event.snapshot);
      _roomsSubject.add(rooms);
    });
    return _roomsSubject;
  }

  Future<List<Room>> getAllRooms() async {
    DataSnapshot snapshot = await _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID + "/rooms")
        .once();
    setRoomsFromSnapshot(snapshot);
    _roomsSubject.add(rooms);
    return rooms;
  }

  List<Room> setRoomsFromSnapshot(DataSnapshot snapshot) {
    if (snapshot.value == null) return [];
    List<Room> rooms = [];
    snapshot.value.values.forEach((valueMap) {
      if (valueMap.containsKey("last_message")) {
        var messageMap = Map<String, dynamic>.from(valueMap["last_message"]);
        if (messageMap.containsKey("attachments")) {
          List<Map<String, dynamic>> attachments =
              List<Map<String, dynamic>>.from(messageMap["attachments"]
                  .map((value) => Map<String, dynamic>.from(value))
                  .toList());

          messageMap['attachments'] = attachments;
        }
        valueMap["last_message"] = messageMap;
      }
      if (valueMap.containsKey("participants")) {
        valueMap['participants'] = valueMap["participants"].keys.map((key) {
          Map<String, dynamic> map =
              Map<String, dynamic>.from(valueMap["participants"][key]);
          map["id"] = key;
          return map;
        }).toList();
      }
      rooms.add(Room.fromJson(Map<String, dynamic>.from(valueMap)));
    });

    return rooms;
  }

  void initParticipant() async {
    DataSnapshot dataSnapshot = await _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID)
        .once();
    _myParticipant = Participant.fromJson(Map.from(dataSnapshot.value));
    if (_myParticipant == null)
      throw "Participant of ID ${_configs.myParticipantID} doesn't exist or the"
          " configs are not right";
  }
}
