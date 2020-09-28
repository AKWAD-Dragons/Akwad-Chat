import 'dart:io';
import 'package:akwad_chat/resources/colors.dart';
import 'package:akwadchat/akwadchat.dart';
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
    SendMessageTask task = widget.room.send(
        Message(text: controller.text, attachments: [
      ChatAttachment(key: "image", type: AttachmentTypes.IMAGE, file: _image)
    ]));
    task.addOnProgressListener((_) {
      setState(() {
        progress =
            (task.totalDone / task.totalSize * 100).toStringAsPrecision(3) +
                "%";
      });
    });
    task.addOnCompleteListener((List<ChatAttachment> attachements) {
      setState(() {
        progress = null;
      });
    });

    task.getTaskByKey("image").events.listen((event) {
      if(event is TaskUpdateEvent){

      }
      if(event is TaskCompletedEvent){

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
