import 'package:flutter/material.dart';
import 'package:inldsevak/my_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inldsevak/notification_service.dart';
import './firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Recover lost camera image before anything else
  // This prevents app restart crashes on older Android devices
  await _recoverLostCameraImage();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  // CRITICAL: Register background message handler BEFORE runApp()
  // This is required for Firebase Cloud Messaging background notifications
  final bool messagingSupported =
      kIsWeb || Platform.isAndroid || Platform.isIOS;
  if (messagingSupported) {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  runApp(const MyApp());

  // Initialize notifications after app starts
  if (messagingSupported) {
    await NotificationService.initializeNotification();
  }
}

/// Generate unique message ID from multiple sources for better deduplication
String _generateUniqueMessageId(RemoteMessage message) {
  try {
    // Try multiple sources in order of reliability
    final messageId = message.messageId;
    final data = message.data;
    
    // Primary: Use Firebase message ID if available
    if (messageId != null && messageId.isNotEmpty) {
      return 'fcm_$messageId';
    }
    
    // Secondary: Use notification ID from data
    final notificationId = data['_id'] ?? 
        data['notificationId'] ?? 
        data['messageId'] ?? 
        data['id'];
    
    if (notificationId != null && notificationId.toString().isNotEmpty) {
      return 'data_${notificationId.toString()}';
    }
    
    // Tertiary: Create ID from notification content (title + body + timestamp)
    final title = message.notification?.title ?? data['title'] ?? '';
    final body = message.notification?.body ?? data['body'] ?? data['message'] ?? '';
    final module = data['module'] ?? '';
    final moduleId = data['moduleId'] ?? '';
    
    // Create a hash from content (for notifications without IDs)
    final contentHash = '${title}_${body}_${module}_${moduleId}'.hashCode;
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Round to seconds
    
    return 'content_${contentHash}_$timestamp';
  } catch (e) {
    // Ultimate fallback: timestamp-based ID
    return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Note: retrieveLostData() does not prevent Android SIGKILL
/// It only helps when Activity is paused, not when process is killed
/// Removed to avoid unnecessary overhead
Future<void> _recoverLostCameraImage() async {
  // No-op: retrieveLostData doesn't prevent SIGKILL on low-RAM devices
  // The real fix is using low-res camera capture (720x720, quality 40)
}

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // Only handle background messages on supported platforms.
  final bool messagingSupported =
      kIsWeb || Platform.isAndroid || Platform.isIOS;
  if (!messagingSupported) return;

  // CRITICAL: Check for duplicates IMMEDIATELY before ANY processing
  // This must happen BEFORE Firebase.initializeApp() to prevent Firebase auto-display
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Generate a unique message ID from multiple sources for better deduplication
    final messageId = _generateUniqueMessageId(message);
    
    // ATOMIC CHECK: Check and mark as processed in one operation
    final processedMessages = prefs.getStringList('processed_background_messages') ?? [];
    
    // Check if this message was already processed
    if (processedMessages.contains(messageId)) {
      print("📬 ⚠️ [Background Handler] Duplicate notification detected (ID: $messageId) - SKIPPING ENTIRELY");
      return; // Exit immediately - don't process at all
    }
    
    // Mark message as processed IMMEDIATELY (before any other processing)
    processedMessages.add(messageId);
    
    // Keep only last 1000 message IDs to prevent storage bloat
    if (processedMessages.length > 1000) {
      processedMessages.removeRange(0, processedMessages.length - 1000);
    }
    
    // Save immediately to prevent race conditions
    await prefs.setStringList('processed_background_messages', processedMessages);
    print("📬 [Background Handler] Message marked as processed (ID: $messageId) - proceeding");
  } catch (e) {
    print("❌ [Background Handler] Error in deduplication check: $e");
    // If deduplication fails, continue but log the error
  }

  try {
    print("📬 [Background Handler] Starting background message handler");
    print(
      "📬 [Background Handler] Notification title: ${message.notification?.title}",
    );
    print(
      "📬 [Background Handler] Notification body: ${message.notification?.body}",
    );
    print("📬 [Background Handler] Data: ${message.data}");
    print("📬 [Background Handler] Message ID: ${message.messageId}");

    await Firebase.initializeApp();
    print("📬 [Background Handler] Firebase initialized");

    // Initialize local notifications for showing the notification
    await NotificationService.initializeLocalNotificationForBackground();
    print("📬 [Background Handler] Local notifications initialized");

    // Show the notification (with built-in deduplication)
    await NotificationService.showFlutterNotificationInBackground(message);
    print("📬 [Background Handler] Notification shown");

    // Store notification data for tracking when app is closed
    await NotificationService.storeBackgroundNotification(message);
    print("📬 [Background Handler] Notification stored");

    // CRITICAL: DO NOT call APIs in background handler
    // Android/iOS Doze mode and App Standby will kill isolates and block HTTP calls
    // Instead, only set flags - APIs will be called when app resumes
    final prefsForFlags = await SharedPreferences.getInstance();
    await prefsForFlags.setBool('showNotification', true);
    await prefsForFlags.setBool('needsDataRefresh', true);

    // CRITICAL: Verify the write was successful
    // Reload SharedPreferences to ensure the write is committed
    await prefsForFlags.reload();
    final verifyFlag = prefsForFlags.getBool('showNotification') ?? false;
    if (verifyFlag) {
      print(
        "📬 [Background Handler] ✅ Verified: showNotification flag is TRUE in SharedPreferences",
      );
    } else {
      print(
        "⚠️ [Background Handler] WARNING: showNotification flag verification failed, retrying...",
      );
      // Retry setting the flag
      await prefsForFlags.setBool('showNotification', true);
      await prefsForFlags.reload();
      final retryVerify = prefsForFlags.getBool('showNotification') ?? false;
      print(
        "📬 [Background Handler] Retry verification: ${retryVerify ? 'SUCCESS' : 'FAILED'}",
      );
    }

    // Log notification details for debugging (especially for chat notifications)
    final module = message.data['module'] ?? 'unknown';
    final type = message.data['type'] ?? 'unknown';
    print("📬 [Background Handler] Module: $module, Type: $type");
    print(
      "📬 [Background Handler] ✅ Flags set - showNotification=TRUE, APIs will be called when app resumes",
    );
  } catch (e, stackTrace) {
    print("❌ [Background Handler] Error in handleBackgroundMessage: $e");
    print("❌ [Background Handler] Stack trace: $stackTrace");
    // Even if there's an error, try to set the notification flag
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showNotification', true);
      await prefs.setBool('needsDataRefresh', true);
      // Verify the write
      await prefs.reload();
      final verifyFlag = prefs.getBool('showNotification') ?? false;
      print(
        "📬 [Background Handler] Set notification flags as fallback - verified: $verifyFlag",
      );
    } catch (prefError) {
      print(
        "❌ [Background Handler] Error setting notification flags: $prefError",
      );
    }
  }
}
