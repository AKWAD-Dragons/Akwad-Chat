import 'FirebaseChatConfigs.dart';
import 'models/Lobby.dart';

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
