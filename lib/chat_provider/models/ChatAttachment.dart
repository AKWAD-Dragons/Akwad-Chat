import 'dart:io';

abstract class ChatAttachment{
  String fileLink;
  File file;
  String type;
  String format;

  Future<void> uploadFileSetLink();
}