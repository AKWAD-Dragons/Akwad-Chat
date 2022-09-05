import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';

import '../FirebaseChatConfigs.dart';
import 'Participant.dart';
import 'Room.dart';

//Lobby contains User Rooms(without messages essentially only contains last_message)
//and listen to it's updates
//the use case in mind was to use it to view Room details in a list of rooms

class Lobby {
  FirebaseChatConfigs _configs;
  DatabaseReference _dbr;
  Participant _myParticipant;
  Map<String, Room> rooms = {};
  Map<String, dynamic> _userRoomConfigs = {};
  BehaviorSubject<Room> _roomsSubject = BehaviorSubject<Room>();
  Map<String, StreamSubscription> stSubs = {};
  StreamSubscription lobbySubscription;

  Lobby() {
    _configs = FirebaseChatConfigs.instance;
    _dbr = FirebaseDatabase.instance.reference();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  //listen to lobby rooms updates(last_message, new participants, etc)
  Stream<Room> getLobbyListener() {
    //get user rooms keys
    getLobbyRooms().then((List<Room> lobbyRooms) {
      _setLobbyRoomsListeners();
      lobbyRooms.forEach((Room room) {
        if (stSubs.containsKey(room.id)) {
          stSubs[room.id].cancel();
        }
        stSubs[room.id] = _dbr
            .child(_configs.roomsLink + "/" + room.id)
            .onValue
            .listen((Event roomSnapshot) {
          Room room = _parseRoomFromSnapshotValue(
              roomSnapshot.snapshot.key, roomSnapshot.snapshot.value);
          bool isDeleted = false;
          if (room.lastMessage != null &&
              _userRoomConfigs.containsKey(room.id) &&
              _userRoomConfigs[room.id].containsKey("deleted_to")) {
            isDeleted = room.lastMessage.id
                    .compareTo(_userRoomConfigs[room.id]['deleted_to']) <=
                0;
          }
          if (isDeleted) {
            return;
          }
          rooms[room.id] = room;
          _roomsSubject.add(room);
        });
      });
    });
    return _roomsSubject;
  }

  //get unread rooms count
  Future<int> getUnreadRoomsCount() async {
    int unreadRoomsCount = 0;
    if (rooms == null) {
      rooms = await getAllRooms();
    }
    rooms.forEach((String key, Room room) {
      if (room.unreadMessagesCount > 0) {
        unreadRoomsCount++;
      }
    });
    return unreadRoomsCount;
  }

  //get lobby rooms
  Future<List<Room>> getLobbyRooms() async {
    DataSnapshot snapshot = await _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID + '/rooms')
        .once();
    List<Room> rooms = [];
    if (snapshot.value != null) {
      snapshot.value.forEach((key, value) {
        Room room = _parseRoomFromSnapshotValue(key, value);
        rooms.add(room);
        if (room.userRoomData != null) {
          _userRoomConfigs[key] = room.userRoomData;
        }
      });
    }
    return rooms;
  }

  _setLobbyRoomsListeners() async {
    if (lobbySubscription != null) {
      lobbySubscription.cancel();
    }
    lobbySubscription = _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID + '/rooms')
        .onValue
        .listen((event) {
      Room room =
          _parseRoomFromSnapshotValue(event.snapshot.key, event.snapshot.value);
      if (room != null) {
        _userRoomConfigs[room.id] = room.userRoomData;
      }
    });
  }

  //get rooms without listening to them
  Future<Map<String, Room>> getAllRooms() async {
    DataSnapshot snapshot = await _dbr
        .child(_configs.usersLink + "/" + _configs.myParticipantID + "/rooms")
        .once();
    List<Future<DataSnapshot>> futures = [];
    if (snapshot.value?.values != null) {
      snapshot.value.values.forEach((valueMap) {
        futures
            .add(_dbr.child(_configs.roomsLink + "/" + valueMap['id']).once());
      });
    }
    List<DataSnapshot> dataSnaps = await Future.wait(futures);
    dataSnaps = _filterDataSnaps(snapshot, dataSnaps);
    rooms = _parseRoomsFromSnapshots(dataSnaps);
    return rooms;
  }

  List<DataSnapshot> _filterDataSnaps(
      DataSnapshot lobby, List<DataSnapshot> rooms) {
    dynamic lobbyRooms = lobby.value.values;
    return rooms.where((room) {
      var lobbyRoom =
          lobbyRooms.firstWhere((lobbyRoom) => lobbyRoom['id'] == room.key);
      if (!lobbyRoom.containsKey('data') ||
          !lobbyRoom['data'].containsKey('deleted_to')) {
        return true;
      }
      if (!room.value.containsKey('last_message')) {
        return true;
      }
      return room.value['last_message']['id']
              .compareTo(lobbyRoom['data']['deleted_to']) >
          0;
    }).toList();
  }

  //parse rooms from snapshot value
  Map<String, Room> _parseRoomsFromSnapshots(List<DataSnapshot> snapshots) {
    Map<String, Room> rooms = {};
    for (DataSnapshot dataSnap in snapshots) {
      if (dataSnap == null) continue;
      rooms[dataSnap.key] =
          _parseRoomFromSnapshotValue(dataSnap.key, dataSnap.value);
    }

    return rooms;
  }

  //parse room from snapshot value
  Room _parseRoomFromSnapshotValue(String key, dynamic valueMap) {
    if (valueMap == null) return null;
    valueMap['messages'] = null;
    valueMap['id'] = key;
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
    if (valueMap.containsKey('data')) {
      valueMap['data'] = Map<String, dynamic>.from(valueMap['data']);
    }
    if (valueMap.containsKey("participants")) {
      valueMap['participants'] = valueMap["participants"].keys.map((key) {
        Map<String, dynamic> map =
            Map<String, dynamic>.from(valueMap["participants"][key]);
        map["id"] = key;
        return map;
      }).toList();
    }
    return Room.fromJson(Map<String, dynamic>.from(valueMap));
  }

  //gets current participant data from RealTime DB
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
