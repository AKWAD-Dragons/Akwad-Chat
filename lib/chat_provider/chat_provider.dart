import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'FirebaseChatConfigs.dart';
import 'models/Lobby.dart';

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

  Future<void> init(Function onTokenExpired) async {
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
        await FirebaseAuth.instance
            .signInWithCustomToken(onTokenExpired())
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

  Lobby getLobby() {
    if (!_isInit) {
      throw "must call init";
    }
    return _lobby;
  }

  Future<void> subscribeToNotifications() async {
    await firebaseMessaging
        .subscribeToTopic(FirebaseChatConfigs.instance.myParticipantID);
  }

  Future<void> unsubscribeFromNotifications() async {
    await firebaseMessaging
        .unsubscribeFromTopic(FirebaseChatConfigs.instance.myParticipantID);
  }
}

class AttachmentTypes {
  static const String IMAGE = 'image',
      VIDEO = 'video',
      AUDIO = 'audio',
      FILE = "file";
}
