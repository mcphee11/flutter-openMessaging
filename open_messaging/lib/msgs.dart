import 'package:flutter/material.dart';
//import 'package:open_messaging/classes.dart'; //json quickReplies json object

class ChatMessage extends StatelessWidget {
  final String text;
  final String user;
  final String attachment;
  final String url;
  final bool richMedia;
  // ignore: prefer_typing_uninitialized_variables
  final payload;
  const ChatMessage(
      {Key? key, required this.text,
      required this.user,
      required this.richMedia,
      required this.attachment,
      required this.url,
      this.payload}) : super(key: key); //gets the text msg as well as the user name

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: (user == 'Inbound')
          ? const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 80.0,
            )
          : const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: (user == 'Inbound')
            ? Theme.of(context).primaryColor
            : Colors.orange[50], //Chat bubble color
        borderRadius: (user == 'Inbound')
            ? const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            user,
            style: const TextStyle(
              // color: (user == 'Customer')
              //     ? Theme.of(context).secondaryHeaderColor
              //     : Theme.of(context).primaryColor, //Chat name color
              fontSize: 16.0,
              fontWeight: FontWeight.w900,
            ),
          ), //adds name to message
          const SizedBox(
            height: 8.0,
          ),
          (attachment == "" &&
                  text.startsWith('https://') == false &&
                  richMedia == false)
              ? Text(
                  text, //adds text to each msg box
                  style: const TextStyle(
                    // color: (user == 'Customer')
                    //     ? Theme.of(context).secondaryHeaderColor
                    //     : Theme.of(context).primaryColor, //Chat text color
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : (text.startsWith('https://') == true && richMedia == false)
                  ? Image.network(text)
                  : (attachment == "Image")
                      ? Image.network(url)
                      : (richMedia == true)
                          ? ElevatedButton(onPressed: () {}, child: Text(text))
                          : const Text('Last Else')
        ],
      ),
    );
  }
}
