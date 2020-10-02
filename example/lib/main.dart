import 'package:akwad_chat/messaging_bar.dart';
import 'package:akwadchat/akwadchat.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
String token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTYwMTY1NDA0OSwiZXhwIjoxNjAxNjU3NjQ5LCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay1ndjFxbUBha3dhZGNoYXR0ZXN0LmlhbS5nc2VydmljZWFjY291bnQuY29tIiwic3ViIjoiZmlyZWJhc2UtYWRtaW5zZGstZ3YxcW1AYWt3YWRjaGF0dGVzdC5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsInVpZCI6Ii1NSWUwSmRKSVhtTnN2UElrbWROIn0.gT73zG87cVtwSVPzLsHaJUGJaE_TT2Sai7DMo2q37t1jNLbkIRXwE3F8gbgEEeZeoX4n924F695lfbyrtYfOJbSXCPIWHtQIOaZ7n_LYRwg2cF_VMkVJKT3xIMqjVUI3-xXaO59TJDDnXwHxkLXOzAtw-doFwfH8aKax9hNt-w2RpKwidRinD-7djAsbHWGbsku82RdRxh1qe85q4t5INASUS8C8C2UdXbJeqqN_4VO3N10PvHA-e8UV3NqiUMDEThuto493PPqfjlNP3V9oIhj16ojxs6n9Jjw5MU2FBmZcsqnKXFbadkCg6wo2A1oksu0ysx5rjfItpAXCiHDpQg";
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
  ChatProvider chatProvider;

  @override
  void initState() {
    FirebaseChatConfigs.instance.init(
        usersLink: "Users", roomsLink: "Rooms", myParticipantToken: token);
    chatProvider = ChatProvider();
    getLobby();
    super.initState();
  }

  getLobby() async {
    lobby = await chatProvider.getLobby();

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
