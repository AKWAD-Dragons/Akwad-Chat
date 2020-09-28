import 'package:akwad_chat/bloc/bloc.dart';
import 'package:akwadchat/chat_provider/chat_provider.dart';
import 'chat_event.dart';

class ChatBloc extends BLoC<ChatEvent> {
  ChatBloc();
  ChatProvider chatProvider;
  String userChatId;
  @override
  Future<void> dispatch(ChatEvent event) async {
    if (event is ChatScreenLaunched) {
      await initChatProvider();
    }
  }

  initChatProvider() async {
    //showLoadingDialog();

    // await _listenToUserChatrooms();
  }
}
