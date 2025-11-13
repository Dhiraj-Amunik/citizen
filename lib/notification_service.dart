import 'dart:developer';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/features/notification/view_model/notification_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // Only handle background messages on supported platforms.
    final bool messagingSupported = kIsWeb || Platform.isAndroid || Platform.isIOS;
    if (!messagingSupported) return;

    await Firebase.initializeApp();
    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

  static Future<void> initializeNotification() async {
    final bool messagingSupported = kIsWeb || Platform.isAndroid || Platform.isIOS;
    if (!messagingSupported) return;

    await requestNotificationPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showFlutterNotification(message);
    });

    await _getFcmToken();

    await _initializeLocalNotification();

    // await _getInitialNotification();
  }

  static Future<void> _getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
    } catch (e) {
      // Token retrieval failed or not supported on this platform
      log('FCM getToken error: $e');
    }
  }

  //display local notification
  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic>? data = message.data;

    String title = notification?.title ?? data['title'] ?? 'No Title';
    String body = notification?.body ?? data['body'] ?? 'No Body';

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'org.amunik.sevak',
      'SEVAK',
      channelDescription: 'Notification channel for SEVAK',
      priority: Priority.high,
      importance: Importance.high,
    );

    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showNotification', true);

    if (RouteManager.context.mounted) {
      RouteManager.context
              .read<UpdateNotificationViewModel>()
              .showNotification =
          true;
    }
  }

  // Request user permissions
  static Future<void> requestNotificationPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
      announcement: true,
      providesAppNotificationSettings: true,
    );
  }

  //init local notification
  static Future<void> _initializeLocalNotification() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings iOSInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await flutterLocalNotificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("User tapped notification: ${response.payload}");

        /// Handle Navigation
        ///
      },
    );
  }

  // //termination state
  // static Future<void> _getInitialNotification() async {
  //   log("------------------------------------->");
  //   RemoteMessage? message = await FirebaseMessaging.instance
  //       .getInitialMessage();

  //   if (message != null) {
  //     print(
  //       "App launched from terminated state via notification: ${message.data}",
  //     );
  //   }
  // }
}
