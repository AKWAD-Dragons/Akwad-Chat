import 'package:rxdart/rxdart.dart';

import 'models/Room.dart';

class ChatProvider {
  var user_id;
  var config;

  ChatProvider(this.config, this.user_id);

  BehaviorSubject<List<Room>> getRoomsListener() {
    return Room.listenToAll("${config.userNodeLink}/$user_id/chat");
  }
}
