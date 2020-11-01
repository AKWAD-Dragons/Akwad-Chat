import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'FirebaseChatConfigs.dart';
import 'models/Lobby.dart';

/*
  ***Starting Point***
  1-Before you call ChatProvider() you will first need to call
    *FirebaseChatConfigs.instance.init()

  2-call chatProvider.init(onTokenExpired)

  3-call chatProvider.getLobby() to start using the current user lobby

*/
class ChatProvider {
  Lobby _lobby;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  bool _isInit = false;

  ChatProvider() {
    if (!FirebaseChatConfigs.instance.isInit) {
      throw "call FirebaseChatConfigs.instance.init() first";
    }
    _lobby = Lobby();
  }

  /*
   *this function must be called to initialize the Chat User and authenticate him

   *Params:
      onTokenExpired()=>String: a callback function that gets called
        if the token passed is expired
        could be used to refresh token passed to FirebaseChatConfigs.init
   */
  Future<void> init(Future<String> onTokenExpired()) async {
    await Firebase.initializeApp();
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseChatConfigs.instance.myParticipantID =
          FirebaseAuth.instance.currentUser.uid;
    }
    UserCredential creds;
    await FirebaseAuth.instance
        .signInWithCustomToken(FirebaseChatConfigs.instance.myParticipantToken)
        .then((value) => creds = value)
        .catchError((ex) async {
      if (ex.code == "invalid-custom-token") {
        print("Token is invalid or expired\nretrying with onTokenExpired");
        FirebaseChatConfigs.instance
            .init(myParticipantToken: await onTokenExpired());
        await FirebaseAuth.instance
            .signInWithCustomToken(
                FirebaseChatConfigs.instance.myParticipantToken)
            .then((value) => creds = value)
            .catchError((e) => throw e);
        return;
      }
      throw ex;
    });
    FirebaseChatConfigs.instance.myParticipantID = creds.user.uid;
    await subscribeToNotifications();
    _isInit = true;
  }

  //Returns lobby if it's safe to use lobby
  Lobby getLobby() {
    if (!_isInit) {
      throw "must call init";
    }
    return _lobby;
  }

  //subscribes user to his notification based on a firebase topic
  //named after his participantID
  Future<void> subscribeToNotifications() async {
    await firebaseMessaging
        .subscribeToTopic(FirebaseChatConfigs.instance.myParticipantID);
  }

  //unsubscribe from notification
  Future<void> unsubscribeFromNotifications() async {
    await firebaseMessaging
        .unsubscribeFromTopic(FirebaseChatConfigs.instance.myParticipantID);
  }

  //TODO::LOGOUT
  Future<void> logout(){

  }
}

class AttachmentTypes {
  static const String IMAGE = 'image',
      VIDEO = 'video',
      AUDIO = 'audio',
      FILE = "file";
}
