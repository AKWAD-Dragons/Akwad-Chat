import 'package:akwad_chat/resources/colors.dart';
import 'package:flutter/material.dart';

class MessagingBar extends StatefulWidget {
  final Widget micIcon;
  final Widget photeIcon;
  MessagingBar({
    @required this.micIcon,
    @required this.photeIcon,
  });

  @override
  _MessagingBarState createState() => _MessagingBarState();
}

class _MessagingBarState extends State<MessagingBar> {
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
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 4,
                        // controller: _controller,
                        decoration: InputDecoration.collapsed(
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
                SizedBox(
                  width: 16,
                ),
                InkWell(
                    onTap: () async {
                      // ImageSource src = await pickerSourceDialog(context);
                      // if (src == null) return;
                      // openImagePicker(src);
                    },
                    child: widget.photeIcon),
                SizedBox(
                  width: 20,
                ),
                InkWell(
                  child: widget.micIcon,
                  // onTap: () =>
                  // showModalBottomSheet(
                  //     context: context,
                  //     builder: (BuildContext context) => AudioBottomSheet()),
                ),
              ],
            ),
          )
        ],
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
