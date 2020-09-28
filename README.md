# akwadchat

This is Akwad's package for chatting

## Usage

### Initialization

first you need to provide the package with the base link of the Users table,the Rooms table and the current user id in firebase

`FirebaseChatConfigs.instance.init(usersLink: "Users", roomsLink: "Rooms", myParticipantID: "testuser");`

then get the current user lobby(a list of chat rooms with some data like title, image, last message, etc)

`ChatProvider chatProvider = ChatProvider();`
`lobby = chatProvider.lobby;`
