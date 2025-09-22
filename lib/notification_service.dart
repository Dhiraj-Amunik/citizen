import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initializeNotification() async {
    await _firebaseMessaging.requestPermission();
    await _getFcmToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("on Message notification: ${message.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("on Message Opened notification: ${message.data}");
    });

  }

  static Future<void> _getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }
}
