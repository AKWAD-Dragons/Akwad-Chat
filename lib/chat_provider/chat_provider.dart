import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'FirebaseChatConfigs.dart';
import 'models/Lobby.dart';

class ChatProvider {
  Lobby _lobby;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  ChatProvider() {
    if (!FirebaseChatConfigs.instance.isInit) {
      throw "call FirebaseChatConfigs.instance.init() first";
    }
    _lobby = Lobby();
  }

  Future<Lobby> getLobby() async {
    await Firebase.initializeApp();
    if(FirebaseAuth.instance.currentUser!=null){
      FirebaseChatConfigs.instance.myParticipantID = FirebaseAuth.instance.currentUser.uid;
      return _lobby;
    }
    UserCredential creds = await FirebaseAuth.instance
        .signInWithCustomToken(FirebaseChatConfigs.instance.myParticipantToken);
    FirebaseChatConfigs.instance.myParticipantID = creds.user.uid;
    await subscribeToNotifications();
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
