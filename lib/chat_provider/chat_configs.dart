class ChatConfigs{
  String dbLink;
  String usersNodeLink;
  String chatNodeLink;

  static ChatConfigs _chatConfigs;
  ChatConfigs._();
  static ChatConfigs instance(){
    _chatConfigs =_chatConfigs??ChatConfigs._();
    return _chatConfigs;
  }

  void setConfigs({String dbLink,String usersNodeLink,String chatNodeLink}){
    this.dbLink=dbLink??this.dbLink;
    this.usersNodeLink=usersNodeLink??this.usersNodeLink;
    this.chatNodeLink=chatNodeLink??this.chatNodeLink;
  }

}