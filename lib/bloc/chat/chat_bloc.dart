import 'package:akwad_chat/bloc/bloc.dart';

import '../../chat_provider/chat_configs.dart';
import '../../chat_provider/chat_configs.dart';
import '../../chat_provider/chat_provider.dart';
import 'chat_event.dart';

class ChatBloc extends BLoC<ChatEvent> {
  ChatBloc();
  ChatProvider chatProvider;
  String userChatId;
  ChatConfigs configs = ChatConfigs.instance();
  @override
  Future<void> dispatch(ChatEvent event) async {
    if (event is ChatScreenLaunched) {
      await initChatProvider();
    }
  }

  initChatProvider() async {
    //showLoadingDialog();
    chatProvider =
        ChatProvider(configs,userChatId);

    // await _listenToUserChatrooms();
  }
}
