import 'package:flutter/material.dart';
import 'package:inldsevak/my_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inldsevak/notification_service.dart';
import './firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
  await NotificationService.initializeNotification();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await NotificationService.initializeNotification();
}
