import 'package:akwad_chat/chat_provider/FirebaseChatConfigs.dart';
import 'package:akwad_chat/chat_provider/models/Lobby.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';

import 'models/Room.dart';

class ChatProvider {
  Lobby _lobby;

  Lobby get lobby => _lobby;

  ChatProvider() {
    if (!FirebaseChatConfigs.instance.isInit) {
      throw "call FirebaseChatConfigs.instance.init() first";
    }
    _lobby = Lobby();
  }
}

class AttachmentTypes {
  static const String IMAGE = 'image', VIDEO = 'video', AUDIO = 'audio';
}
