abstract class ChatEvent{}

class ChatScreenLaunched extends ChatEvent{}

class SendTapped extends ChatEvent{
  String text;
  SendTapped({this.text});
}