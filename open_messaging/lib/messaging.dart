import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_messaging/google_sign_in.dart';
import 'package:open_messaging/main.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'classes.dart';
import 'msgs.dart'; //Class for rendering custom object

class Messaging extends StatefulWidget {
  const Messaging({Key? key}) : super(key: key);

  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> with WidgetsBindingObserver {
  final TextEditingController _controller =
      TextEditingController(); //Capture input
  final ImagePicker _picker = ImagePicker();
  late XFile _image;
  final Storage storage = Storage(); //used for file upload
  final user = FirebaseAuth.instance.currentUser!; //gets the firebase user
  late final Stream<QuerySnapshot> dbMessages = FirebaseFirestore.instance
      .collection('users/${user.uid}/messages')
      .orderBy('time')
      .snapshots();
  late final dbSend =
      FirebaseFirestore.instance.collection('users/${user.uid}/messages');
  final ScrollController _scrollController =
      ScrollController(); //control scroll depth

  late final icon = Provider.of<MessageIcon>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title:
            const Text('Open Messaging', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        actions: [
          TextButton(
            onPressed: () {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.logout();
            },
            child: const Text('Logout'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
            10.0, 0.0, 10.0, 40.0), //spacing for message bubbles
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: dbMessages,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  final data = snapshot.requireData;
                  //print('DATA: ${snapshot.data!.docs.length}');
                  try {
                    Future.delayed(
                        const Duration(seconds: 1),
                        () => {
                              print('delay'),
                              Provider.of<MessageIcon>(context, listen: false)
                                  .updateMessageIcon(false),
                              _scrollController.animateTo(99999999,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut)
                            });
                  } catch (err) {
                    //print(err);
                  }
                  return ListView.builder(
                      itemCount: data.size,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0), //around text box
                      itemBuilder: (context, index) {
                        if (data.docs[index]['richMedia'] ==
                            true) {
                          print('Richmedia');
                          List array = data.docs[index]['attachment'];
                          print('inside RichMedia');
                          array.forEach((arrayMessage) {
                            print(arrayMessage);
                            if ('${arrayMessage['contentType']}' ==
                                'QuickReply') {
                              ChatMessage(
                                  text: '${arrayMessage['quickReply']['text']}',
                                  user: data.docs[index]['direction'],
                                  attachment: data.docs[index]['attachment'],
                                  url: data.docs[index]['url'],
                                  richMedia: data.docs[index]['richMedia']);
                            }
                          });
                        } else {
                          return ChatMessage(
                              text: data.docs[index]['message'],
                              user: data.docs[index]['direction'],
                              attachment: data.docs[index]['attachment'],
                              url: data.docs[index]['url'],
                              richMedia: data.docs[index]['richMedia']);
                        }
                        return Text('No Condition Met');
                      });
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _textComposerWidget(),
    );
  }

  Future<void> _sendMessage(name, url) async {
    if (_controller.text.isNotEmpty && url == 'null') {
      dbSend.add({
        'direction': 'Inbound',
        'message': _controller.text,
        'time': ((DateTime.now().microsecondsSinceEpoch) / 1000).round(),
        'type': 'Text',
        'nickname': (user.displayName)!.split(' ')[0],
        'firstName': user.displayName!.split(' ')[0],
        'lastName': user.displayName!.split(' ')[1],
        'userId': user.uid,
        'image': user.photoURL,
        'attachment': '',
        'filename': '',
        'url': '',
        'richMedia': false,
      });
      _controller.text = '';
      _scrollController.animateTo(99999999,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    if (url != 'null') {
      dbSend.add({
        'direction': 'Inbound',
        'message': _controller.text,
        'time': ((DateTime.now().microsecondsSinceEpoch) / 1000).round(),
        'type': 'Text',
        'nickname': (user.displayName)!.split(' ')[0],
        'firstName': user.displayName!.split(' ')[0],
        'lastName': user.displayName!.split(' ')[1],
        'userId': user.uid,
        'image': user.photoURL,
        'attachment': 'Image',
        'filename': name,
        'url': url,
        'richMedia': false,
      });
      _controller.text = '';
      _scrollController.animateTo(99999999,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  //Visuals for input widget down bottom of app
  Widget _textComposerWidget() {
    return IconTheme(
      data: IconThemeData(
        color: Theme.of(context).secondaryHeaderColor,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.photo_camera),
              iconSize: 25.0,
              onPressed: () => getCamera(),
            ),
            IconButton(
              icon: const Icon(Icons.photo),
              iconSize: 25.0,
              onPressed: () => pickImage(),
            ),
            Flexible(
              child: TextField(
                decoration: const InputDecoration.collapsed(
                    hintText: 'Enter message...'),
                controller: _controller,
                //onSubmitted: ,
                //onTap: () => typing(), //sends typing API to agent
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage('name', 'null'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //access to file explorer
  pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    print('image: ' + image!.name);
    var bytes = await image.length();
    print(bytes);
    _image = image;
    storage
        .uploadFile(image.path, image.name)
        .then((value) => storage.downloadURL(image.name))
        .then((value) => _sendMessage(image.name, value));
  }

  //access to camera
  getCamera() async {
    XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    print('photo name: ' + photo!.name);
    var bytes = await photo.length();
    print(bytes);
    _image = photo;
    storage
        .uploadFile(photo.path, photo.name)
        .then((value) => storage.downloadURL(photo.name))
        .then((value) => _sendMessage(photo.name, value));
  }
}
