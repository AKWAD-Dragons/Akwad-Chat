class FirebaseChatConfigs {
  String _roomsLink;
  String _usersLink;
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

  String get myParticipantID {
    _checkNull(_myParticipantID, "myParticipantID");
    return _myParticipantID;
  }

  bool get isInit=>_isInit;


  void init({String roomsLink, String usersLink, String myParticipantID}) {
    _isInit = true;
    _roomsLink = roomsLink ?? _roomsLink;
    _usersLink = usersLink ?? _usersLink;
    _myParticipantID = myParticipantID ?? _myParticipantID;
  }

  void _checkNull(dynamic variable, String name) {
    if (variable == null) {
      throw "$name is not set";
    }
  }
}
