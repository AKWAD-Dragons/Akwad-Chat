class FirebaseChatConfigs {
  String _roomsLink;
  String _usersLink;
  String _myParticipantToken;
  String _myParticipantID;
  bool _isInit = false;

  static FirebaseChatConfigs _instance;

  static FirebaseChatConfigs get instance{
    if(_instance == null){
      _instance = FirebaseChatConfigs._();
    }
    return _instance;
  }

  FirebaseChatConfigs._();

  String get roomsLink {
    _checkNull(_roomsLink, "roomLink");
    return _roomsLink;
  }

  String get usersLink {
    _checkNull(_usersLink, "usersLink");
    return _usersLink;
  }

  String get myParticipantToken {
    _checkNull(_myParticipantToken, "myParticipantToken");
    return _myParticipantToken;
  }
  String get myParticipantID {
    _checkNull(_myParticipantID, "myParticipantID");
    return _myParticipantID;
  }

  set myParticipantID(String myParticipantID) {
    _myParticipantID = myParticipantID;
  }

  bool get isInit=>_isInit;



  void init({String roomsLink, String usersLink, String myParticipantToken}) {
    _isInit = true;
    _roomsLink = roomsLink ?? _roomsLink;
    _usersLink = usersLink ?? _usersLink;
    _myParticipantToken = myParticipantToken ?? _myParticipantToken;
  }

  void _checkNull(dynamic variable, String name) {
    if (variable == null) {
      throw "$name is not set";
    }
  }
}
