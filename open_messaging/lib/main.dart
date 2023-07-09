import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_messaging/firebase_options.dart';
import 'package:open_messaging/google_sign_in.dart';
import 'package:open_messaging/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Notification Start
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notificaiotns',
    description: 'This channel is used for important notificaitons.',
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print('A background message: ${message.messageId}');
  }
  if (message.data.containsKey('messageText')) {
    // Show notification
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.data['messageTitle'],
      message.data['messageText'],
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description,
            color: Colors.orange,
            playSound: true,
            icon: '@mipmap/ic_launcher'),
      ),
    );
  }
}
// Notification End

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //Firebase Notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => GoogleSignInProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => MessageIcon(),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
              primaryColor: Colors.blue[100],
              secondaryHeaderColor: Colors.black,
              colorScheme:
                  ColorScheme.fromSwatch().copyWith(secondary: Colors.black)),
          debugShowCheckedModeBanner: false,
          home: const LoginPage(),
        ),
      );
}
