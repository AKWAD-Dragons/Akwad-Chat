import 'package:akwad_chat/messaging_bar.dart';
import 'package:akwadchat/akwadchat.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Lobby lobby;
  List<Room> rooms;
  Room selectedRoom;

  @override
  void initState() {
    FirebaseChatConfigs.instance.init(
        usersLink: "Users", roomsLink: "Rooms", myParticipantID: "testuser");
    ChatProvider chatProvider = ChatProvider();
    lobby = chatProvider.lobby;

    lobby.getLobbyListener().listen((List<Room> lobbyRooms) {
      rooms = lobbyRooms;
      if (lobbyRooms.isNotEmpty) {
        setState(() {
          selectedRoom = rooms[0];
        });
        selectedRoom.getRoomListener.listen((_) {
          selectedRoom.setSeen(selectedRoom.messages.last);
          setState(() {});
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat test"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: selectedRoom!=null? ListView.builder(
                  itemCount: selectedRoom.messages?.length??0,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Bubble(
                        alignment: Alignment.centerRight,
                        margin:BubbleEdges.only(top: 16),
                        color: Colors.greenAccent.shade100,
                        child:
                            _buildMessageBubble(selectedRoom.messages[index]));
                  }):Container()),
          Container(
            child: MessagingBar(
              room: selectedRoom,
              micIcon: Icon(Icons.ac_unit),
              photeIcon: Icon(Icons.ac_unit),
            ),
          )
        ],
      ),
    );
  }

  _buildMessageBubble(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        (message.attachments?.isNotEmpty ?? false)
            ? CachedNetworkImage(
                imageUrl: message.attachments[0].fileLink,
                width: 150,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 150,
                  width: 150,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : Container(width: 0,height: 0,),
        (message.text?.isNotEmpty ?? false) ? Text(message.text): Container(width: 0,height: 0,),
      ],
    );
  }
}
