import 'package:akwadchat/chat_provider/models/Room.dart';

abstract class ChatState{}

class ChatRoomIS extends ChatState{
  Room chatRoom;
  ChatRoomIS(this.chatRoom);
}