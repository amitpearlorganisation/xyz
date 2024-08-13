import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("This is background hadler");
 print("Title : ${message.notification?.title}");
 print("Body : ${message.notification?.body}");

}



class FirebaseApi{

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("This is FCM token:\n$fCMToken finish");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
  Future initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Get the token
    await getToken();
  }

  Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('Token: $token');
    return token;
  }

}