import 'package:flutter/material.dart';
import 'package:inldsevak/my_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inldsevak/notification_service.dart';
import './firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());

  // Initialize notifications and background message handler only on
  // platforms where firebase_messaging is supported.
  final bool messagingSupported = kIsWeb || Platform.isAndroid || Platform.isIOS;

  if (messagingSupported) {
    await NotificationService.initializeNotification();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await NotificationService.initializeNotification();
}
