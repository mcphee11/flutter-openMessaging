import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_messaging/google_sign_in.dart';
import 'package:provider/provider.dart';

class Tasks extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!; //gets the firebase user
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Tasks', style: TextStyle(color: Colors.white)),
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
      body: const Text('TASKS'),
    );
  }
}
