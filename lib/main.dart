import 'package:akwad_chat/chat_provider/FirebaseChatConfigs.dart';
import 'package:akwad_chat/chat_provider/chat_provider.dart';
import 'package:akwad_chat/chat_provider/models/Lobby.dart';
import 'package:akwad_chat/chat_provider/models/Message.dart';
import 'package:akwad_chat/messaging_bar.dart';
import 'package:flutter/material.dart';

import 'chat_provider/models/Room.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(seconds: 2));
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

  @override
  void initState() {
    FirebaseChatConfigs.instance.init(
        usersLink: "Users", roomsLink: "Rooms", myParticipantID: "testuser");
    ChatProvider chatProvider = ChatProvider();
    lobby = chatProvider.lobby;

    lobby.getLobbyListener().listen((List<Room> lobbyRooms) {
      rooms=lobbyRooms;
      if(lobbyRooms.isNotEmpty){
        Room room = rooms[0];
        room.getRoomListener.listen((_) {
          print(room.messages.last.text);
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
          Expanded(child: Container()),
          Container(
            child: MessagingBar(
              micIcon: Icon(Icons.ac_unit),
              photeIcon: Icon(Icons.ac_unit),
            ),
          )
        ],
      ),
    );
  }
}
