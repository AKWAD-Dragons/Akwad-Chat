//Firebase Configs for ChatProvider
class FirebaseChatConfigs {
  String _roomsLink;
  String _messagesLink;
  String _usersLink;
  String _myParticipantToken;
  String _myParticipantID;
  bool _isInit = false;

  static FirebaseChatConfigs _instance;

  static FirebaseChatConfigs get instance {
    if (_instance == null) {
      _instance = FirebaseChatConfigs._();
    }
    return _instance;
  }

  FirebaseChatConfigs._();

  String get roomsLink {
    _checkNull(_roomsLink, "roomLink");
    return _roomsLink;
  }

  String get messagesLink {
    _checkNull(_messagesLink, "messagesLink");
    return _messagesLink;
  }

  String get usersLink {
    _checkNull(_usersLink, "usersLink");
    return _usersLink;
  }

  String get myParticipantToken {
    _checkNull(_myParticipantToken, "myParticipantToken");
    return _myParticipantToken;
  }

  //User ID in Realtime DB
  String get myParticipantID {
    _checkNull(_myParticipantID, "myParticipantID");
    return _myParticipantID;
  }

  set myParticipantID(String myParticipantID) {
    _myParticipantID = myParticipantID;
  }

  bool get isInit => _isInit;

  //Example Scheme
  //firebase-project-root:
  //  Rooms:
  //    -Mw91AWdawdaWDew3
  //  Users:
  //    -Mw31sfWdafa2Dewa
  //  Messages:
  //    -RoomKey/
  //      -Message1...
  //roomsLink: link to Rooms node in realtime database
  //  for the example scheme that would be roomLink:"Rooms"
  //messagesLink: link to Messages node in realtime database
  //  for the example scheme that would be messageLink:"Messages"
  //usersLink: link to Users node in realtime database
  //  for the example scheme that would be roomLink:"Users"
  //myParticipantToken: a custom token that expires after one hour
  //  this token could be fetched through the cloud function createUser and refreshToken
  void init(
      {String roomsLink = "Rooms",
      String messagesLink = "Messages",
      String usersLink = "Users",
      String myParticipantToken}) {
    _isInit = true;
    _roomsLink = roomsLink ?? _roomsLink;
    _messagesLink = messagesLink ?? _messagesLink;
    _usersLink = usersLink ?? _usersLink;
    _myParticipantToken = myParticipantToken ?? _myParticipantToken;
  }

  void _checkNull(dynamic variable, String name) {
    if (variable == null) {
      throw "$name is not set";
    }
  }
}
