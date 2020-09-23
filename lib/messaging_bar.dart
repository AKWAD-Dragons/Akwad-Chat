import 'dart:io';

import 'package:akwad_chat/chat_provider/chat_provider.dart';
import 'package:akwad_chat/chat_provider/models/ChatAttachment.dart';
import 'package:akwad_chat/chat_provider/models/Message.dart';
import 'package:akwad_chat/chat_provider/models/Room.dart';
import 'package:akwad_chat/resources/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessagingBar extends StatefulWidget {
  final Widget micIcon;
  final Widget photeIcon;
  final Room room;

  MessagingBar({
    @required this.micIcon,
    @required this.photeIcon,
    this.room,
  });

  @override
  _MessagingBarState createState() => _MessagingBarState();
}

class _MessagingBarState extends State<MessagingBar> {
  File _image;
  final picker = ImagePicker();
  String progress;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: AppColors.chatBG,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      child: TextFormField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 4,
                        // controller: _controller,
                        decoration: InputDecoration.collapsed(
                          hintText: "Type a message",
                          // hintText: AppStrings.typeYourMessage,
                          hintStyle: TextStyle(
                            color: AppColors.gray,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  sendButton()
                ],
              ),
            ),
          ),
          Visibility(
            // visible: !typing,
            child: Row(
              children: <Widget>[
                photoButton(),
                micButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      sendMessage();
    } else {
      print('No image selected.');
    }
  }

  Widget photoButton() {
    return Container(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: progress == null
            ? InkWell(
                onTap: () {
                  getImage();
                },
                child: widget.photeIcon)
            : Text(progress),
      ),
    );
  }

  sendMessage() {
    Map<String, dynamic> tasksMap = widget.room.send(
        Message(text: controller.text, attachments: [
      ChatAttachment(key: "image", type: AttachmentTypes.IMAGE, file: _image)
    ]));
    StorageUploadTask task = tasksMap["image"]['task'];
    task.events.listen((event) {
      if (event.type == StorageTaskEventType.success) {
        setState(() {
          event.snapshot.ref.getDownloadURL();
          progress = null;
        });
      } else {
        setState(() {
          progress = (event.snapshot.bytesTransferred /
                      event.snapshot.totalByteCount *
                      100)
                  .toStringAsPrecision(3) +
              "%";
        });
      }
    });
  }

  Widget micButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 20),
      child: InkWell(
        child: widget.micIcon,
        // onTap: () =>
        // showModalBottomSheet(
        //     context: context,
        //     builder: (BuildContext context) => AudioBottomSheet()),
      ),
    );
  }

  Widget sendButton() {
    return Container(
      child: InkWell(
        onTap: () {
          setState(() {});
        },
        child: Container(
          width: 50,
          height: 50,
          child: Card(
            child: new Icon(
              Icons.send,
              color: AppColors.white,
              size: 18,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            color: AppColors.accentColor,
          ),
        ),
      ),
    );
  }
}
