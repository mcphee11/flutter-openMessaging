// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_messaging/google_sign_in.dart';
import 'package:open_messaging/messaging.dart';
import 'package:open_messaging/tasks.dart';
import 'package:provider/provider.dart';
//import 'package:badges/badges.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

//START saving token profile
  Future<void> saveTokenToDatabase(String token) async {
    //user is logged in for this example
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (kDebugMode) {
      print('Updating Db UserId: $userId Token: $token ');
    }
    await FirebaseFirestore.instance.collection('users/$userId/profile').doc('userInfo').set({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  start() async{
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();
    // Save the initial token to the database
    await saveTokenToDatabase(token!);
    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  @override
  void initState() {
    super.initState();
    start();
    FirebaseMessaging.onMessage.listen((message) async {
    if (kDebugMode) {
      print("New OnMessage:  ${message.messageId}");
    }
    Provider.of<MessageIcon>(context, listen: false).updateMessageIcon(true);
  });
  }
  //END saving token profile

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!; //gets the firebase user
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //const SizedBox(height: 170),
          Center(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(user.photoURL!),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 180.0),
                  child: Text(
                    'Welcome ${user.displayName!}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // icon: Badge(
            //   showBadge: Provider.of<MessageIcon>(context, listen: true).currentValue,
            //   shape: BadgeShape.circle,
            //   position: BadgePosition.topEnd(),
            //   child: const Icon(Icons.message),
            //   badgeContent: const SizedBox(
            //   height: 5,
            //   width: 5,
            // ),
            // ),
            icon: Icon(Icons.message),
            label: 'Messaging',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_sharp),
            label: 'Tasks',
          ),
        ],
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        // ignore: avoid_print
        onTap: (onItemTapped) => onItemTapped == 0
            ? Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Messaging()))
            : Navigator.push(context, MaterialPageRoute(builder: (_) => const Tasks())),
      ),
    );
  }
}
