import 'package:akwad_chat/messaging_bar.dart';
import 'package:akwadchat/akwadchat.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

String token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTYwMjc2ODY1MSwiZXhwIjoxNjAyNzcyMjUxLCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay1ndjFxbUBha3dhZGNoYXR0ZXN0LmlhbS5nc2VydmljZWFjY291bnQuY29tIiwic3ViIjoiZmlyZWJhc2UtYWRtaW5zZGstZ3YxcW1AYWt3YWRjaGF0dGVzdC5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsInVpZCI6Ii1NSmdTQktZZWgwaFJweHRVSkNkIn0.sg2yVL8j73mf2rzwPXzWarwYDNTA-XKCGVY_HSW4_hPyiLiLd0DkKUtpjYNpEOo2DohcfYMsRB9wOQCLGBa9RsT08Y1BkKyFtMUwIb6UkFCe8Hm6cLi_G8psQgT2XFd0Gue2c8IHi2hFGHfEOR2B1u-2rywTkueEaghlJ5mmgUXDZUTvwiGVaDYA_a_Xv3c030vJWC03X1l4Sh1Z84eQyL8nOOqhTEdIZANwHe8F0Pnp7BdCjsHxthtBJDaxkRWlhMdMGcvxGeQcmV2nH1-TzEdzpJu2WXGxCmjsmQH0VpltkRSUSKnboX7KyQyMC3VXqvCKbALhk2BaZc9wQQMU2w";
String fakeToken = "eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTYwMjc1Mzk2MCwiZXhwIjoxNjAyNzU3NTYwLCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay1ndjFxbUBha3dhZGNoYXR0ZXN0LmlhbS5nc2VydmljZWFjY291bnQuY29tIiwic3ViIjoiZmlyZWJhc2UtYWRtaW5zZGstZ3YxcW1AYWt3YWRjaGF0dGVzdC5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsInVpZCI6Ii1NSmZXQ29WR3pxQmd2ZHpMY3JBIn0.sJexS6Q56kelNytzXSmQmgRC6CtgWm9UmtN55XzOgIxshKoqhVGNbZVbOafVu7A6RIGININhHsQ0A_xWhGJDO-JQ07YzwBq4ZjBNxnAc_UP-vAJe4me3kQQo6KSgjE232b57vMOTlhmvM0IRxvprgx-AYBMae7bD9Z8vSmvzBwZGW0-tEZzLy8sLUO6IxyaoLZTAOHqDXGZLVB5PVD58ItYcwUGVHU7Qmt74XN9CB3uF35cMUEVfqlXJJ1rGWWbzZLapOygcB2Gwz4kLmCdBSY8cVJjdLYnQNQJ2sP0mf83kBhUZCSWdMBlPVwXofXtKLU3SHpiYSNsoOg1LXCn6UQ";
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
        usersLink: "Users", roomsLink: "Rooms", myParticipantToken: fakeToken);
    chatProvider = ChatProvider();
    getLobby();
    super.initState();
  }

  getLobby() async {
    await chatProvider.init(() => token);
    lobby = chatProvider.getLobby();

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
