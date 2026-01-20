import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/features/notification/view_model/notification_view_model.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart'
    as nm;
import 'package:inldsevak/features/nearest_member/view_model/my_member_message_view_model.dart';
import 'package:inldsevak/features/nearest_member/view_model/nearest_member_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as woh;
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/financial_help_messages_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart'
    as complaint;
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/model/request/my_complaint_request_model.dart';
import 'package:inldsevak/features/nearest_member/services/nearest_member_repository.dart';
import 'package:inldsevak/features/notification/services/notification_repository.dart';
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
    final bool messagingSupported =
        kIsWeb || Platform.isAndroid || Platform.isIOS;
    if (!messagingSupported) return;

    try {
      await Firebase.initializeApp();
      await _initializeLocalNotification();
      await _showFlutterNotification(message);

      // Store notification data for tracking when app is closed
      await storeBackgroundNotification(message);

      // CRITICAL: DO NOT call APIs in background handler
      // Android/iOS Doze mode and App Standby will kill isolates and block HTTP calls
      // Instead, only set flags - APIs will be called when app resumes
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showNotification', true);
      await prefs.setBool('needsDataRefresh', true);

      // Log notification details for debugging (especially for chat notifications)
      final module = message.data['module'] ?? 'unknown';
      final type = message.data['type'] ?? 'unknown';
      log(
        "📬 Background notification received - Module: $module, Type: $type - flags set, APIs will be called when app resumes",
      );
      log(
        "📬 Background notification - showNotification flag set to TRUE in SharedPreferences",
      );
    } catch (e) {
      log("❌ Error in firebaseMessagingBackgroundHandler: $e");
      // Even if there's an error, try to set the flags
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showNotification', true);
        await prefs.setBool('needsDataRefresh', true);
      } catch (prefError) {
        log("Error setting notification flags: $prefError");
      }
    }
  }

  /// Store notification received when app is closed/background
  static Future<void> storeBackgroundNotification(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = message.data;
      final notification = message.notification;

      // Create notification data object
      final notificationData = {
        '_id':
            data['_id'] ??
            data['notificationId'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'title': notification?.title ?? data['title'] ?? 'Notification',
        'message': notification?.body ?? data['message'] ?? data['body'] ?? '',
        'type': data['type'] ?? 'general',
        'module': data['module'],
        'moduleId': data['moduleId'],
        'userId': data['userId'],
        'read': false,
        'isActive': true,
        'isDeleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        // Store additional data from payload
        'data': data,
      };

      // Get existing stored notifications
      final storedNotificationsJson =
          prefs.getStringList('background_notifications') ?? [];
      final storedNotifications = storedNotificationsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      // Check if notification already exists (by ID)
      final notificationId = notificationData['_id'] as String;
      final exists = storedNotifications.any((n) => n['_id'] == notificationId);

      if (!exists) {
        // Add new notification
        storedNotifications.add(notificationData);

        // Keep only last 100 notifications to prevent storage bloat
        if (storedNotifications.length > 100) {
          storedNotifications.removeRange(0, storedNotifications.length - 100);
        }

        // Save back to SharedPreferences
        final updatedJson = storedNotifications
            .map((n) => jsonEncode(n))
            .toList();
        await prefs.setStringList('background_notifications', updatedJson);

        log("📬 Stored background notification: ${notificationData['title']}");
      }

      // Mark that there are new notifications
      // Always set this flag when a notification is received
      await prefs.setBool('showNotification', true);
      await prefs.setBool('hasBackgroundNotifications', true);
      log(
        "📬 Background notification stored - showNotification flag set to true",
      );
    } catch (e) {
      log("Error storing background notification: $e");
      // Even if storing fails, try to set the notification flag
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showNotification', true);
        log("📬 Set showNotification flag as fallback");
      } catch (prefError) {
        log("Error setting notification flag: $prefError");
      }
    }
  }

  /// Get stored background notifications
  static Future<List<Map<String, dynamic>>>
  getStoredBackgroundNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedNotificationsJson =
          prefs.getStringList('background_notifications') ?? [];

      return storedNotificationsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      log("Error retrieving stored background notifications: $e");
      return [];
    }
  }

  /// Clear stored background notifications
  static Future<void> clearStoredBackgroundNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('background_notifications');
      await prefs.setBool('hasBackgroundNotifications', false);
    } catch (e) {
      log("Error clearing stored background notifications: $e");
    }
  }

  /// Clean up old processed message IDs (called periodically)
  static Future<void> cleanupOldProcessedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final processedMessages = prefs.getStringList('processed_background_messages') ?? [];
      
      // Keep only last 500 message IDs (reduce from 1000 to prevent storage issues)
      if (processedMessages.length > 500) {
        final cleaned = processedMessages.sublist(processedMessages.length - 500);
        await prefs.setStringList('processed_background_messages', cleaned);
        log("📬 Cleaned up old processed messages: ${processedMessages.length - 500} removed");
      }
      
      // Also clean up shown notification IDs
      final shownNotifications = prefs.getStringList('shown_notification_ids') ?? [];
      if (shownNotifications.length > 500) {
        final cleaned = shownNotifications.sublist(shownNotifications.length - 500);
        await prefs.setStringList('shown_notification_ids', cleaned);
        log("📬 Cleaned up old shown notification IDs: ${shownNotifications.length - 500} removed");
      }
    } catch (e) {
      log("Error cleaning up processed messages: $e");
    }
  }

  static Future<void> initializeNotification() async {
    final bool messagingSupported =
        kIsWeb || Platform.isAndroid || Platform.isIOS;
    if (!messagingSupported) return;

    await requestNotificationPermission();

    // CRITICAL: For iOS, prevent auto-display of notifications in foreground
    // This ensures we have full control over notification display
    // Android handles this differently - deduplication logic handles duplicates
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: false, // Don't auto-show in foreground
        badge: false,
        sound: false,
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // App in foreground - fetch latest data
      _showFlutterNotification(message);
      fetchLatestDataOnNotification();
    });

    // Handle notification taps when app is in background/foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigationFromMessage(message);
      // Fetch latest data when notification opens app
      fetchLatestDataOnNotification();
    });

    // Handle notification that opened the app from terminated state
    await _getInitialNotification();

    await _getFcmToken();

    await _initializeLocalNotification();

    // Clean up old processed messages on app start
    await cleanupOldProcessedMessages();

    // CRITICAL: Check for notification flags after initialization
    // This ensures the red dot appears when app is opened after receiving notification while locked
    // Use a delay to ensure app is fully initialized and providers are ready
    Future.delayed(const Duration(milliseconds: 500), () {
      checkAndRefreshDataIfNeeded();
    });
  }

  /// Fetch latest data (complaints, wall of help, nearest member) when notification is received
  /// Works in foreground mode using Provider context
  /// This updates view models which will trigger GIF animation update in indl_view.dart
  static void fetchLatestDataOnNotification() {
    try {
      final navigatorContext = RouteManager.navigatorKey.currentContext;
      if (navigatorContext != null && navigatorContext.mounted) {
        // Use WidgetsBinding to ensure UI updates happen on next frame
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (navigatorContext.mounted) {
            // Fetch complaints - this will update totalUnreadCount and trigger GIF animation
            try {
              final complaintsVm = navigatorContext.read<ComplaintsViewModel>();
              complaintsVm.getComplaints(
                showLoader: false,
                preserveSearch: true,
              );
              log("📬 Fetched complaints on notification - GIF will update");
            } catch (e) {
              log("Error fetching complaints on notification: $e");
            }

            // Fetch wall of help messages - this will update totalUnreadCount and trigger GIF animation
            try {
              final financialHelpVm = navigatorContext
                  .read<FinancialHelpMessagesViewModel>();
              financialHelpVm.getMyFinancialHelpRequestMessages();
              log(
                "📬 Fetched wall of help messages on notification - GIF will update",
              );
            } catch (e) {
              log("Error fetching wall of help messages on notification: $e");
            }

            // Fetch nearest member messages (if party member) - this will update totalUnreadCount and trigger GIF animation
            try {
              final nearestMemberVm = navigatorContext
                  .read<MyMemberMessageViewModel>();
              if (nearestMemberVm.token != null &&
                  nearestMemberVm.token!.isNotEmpty) {
                nearestMemberVm.getAllChats();
                log(
                  "📬 Fetched nearest member messages on notification - GIF will update",
                );
              }
            } catch (e) {
              log("Error fetching nearest member messages on notification: $e");
            }

            // Also fetch nearest member unread count
            try {
              final nearestMemberUnreadVm = navigatorContext
                  .read<NearestMemberViewModel>();
              nearestMemberUnreadVm.getUnreadChatCount();
              log(
                "📬 Fetched nearest member unread count on notification - GIF will update",
              );
            } catch (e) {
              log(
                "Error fetching nearest member unread count on notification: $e",
              );
            }

            // BEST LOGIC: Fetch notifications and update dot when new notification arrives
            try {
              final updateNotificationVm = navigatorContext
                  .read<UpdateNotificationViewModel>();

              // OPTIMISTIC UPDATE: Immediately show dot when notification arrives
              // This provides instant feedback to user
              updateNotificationVm.showNotification = true;
              log(
                "📬 ✅ Optimistic update: Dot shown immediately on new notification",
              );

              // Don't fetch notifications automatically - this can hide the dot prematurely
              // The dot will be verified when user opens notifications view
              // This prevents the dot from disappearing before user sees the notification
              log(
                "📬 ✅ Dot will be verified when user opens notifications view",
              );
            } catch (e) {
              log("❌ Error fetching notifications on notification: $e");
              // Fallback: keep dot shown if API check fails (optimistic approach)
              try {
                final updateNotificationVm = navigatorContext
                    .read<UpdateNotificationViewModel>();
                updateNotificationVm.showNotification = true;
                log("📬 Fallback: Keep notification dot shown");
              } catch (e2) {
                log("Error setting notification dot: $e2");
              }
            }
          }
        });
      } else {
        // Context not available - set flag to fetch when app opens
        _setDataRefreshFlag();
      }
    } catch (e) {
      log("Error in fetchLatestDataOnNotification: $e");
      // Set flag as fallback
      _setDataRefreshFlag();
    }
  }

  /// Fetch latest data in background/terminated mode using repositories directly
  static Future<void> fetchLatestDataInBackground() async {
    try {
      log("📬 [fetchLatestDataInBackground] Starting background data fetch");

      // Get token from secure storage
      final token = await SessionController.instance.getToken();
      if (token == null || token.isEmpty) {
        log(
          "⚠️ [fetchLatestDataInBackground] No token available for background data fetch",
        );
        // Still set notification flag even without token
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('showNotification', true);
          log(
            "📬 [fetchLatestDataInBackground] Set notification flag without token",
          );
        } catch (e) {
          log("Error setting notification flag without token: $e");
        }
        _setDataRefreshFlag();
        return;
      }

      log(
        "📬 [fetchLatestDataInBackground] Token available, starting API calls",
      );

      // IMPORTANT: Fetch notifications list FIRST to ensure dot appears
      // This is critical for showing the notification icon dot
      // Use timeout to ensure it completes quickly in background
      try {
        log("📬 [fetchLatestDataInBackground] Calling notification API...");
        final notificationRepo = NotificationRepository();
        final response = await notificationRepo
            .getNotificationsApi(token: token)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                log(
                  "⚠️ [fetchLatestDataInBackground] Notification API timeout",
                );
                throw TimeoutException("Notification API timeout");
              },
            );
        final prefs = await SharedPreferences.getInstance();

        if (response.data?.responseCode == 200) {
          // Mark that there are new notifications if we got a successful response
          // Even if the list is empty, we still received a notification, so show the dot
          await prefs.setBool('showNotification', true);
          log(
            "📬 ✅ [fetchLatestDataInBackground] Fetched notifications - response code: ${response.data?.responseCode}, count: ${response.data?.data?.length ?? 0}",
          );
        } else {
          // Even if API call fails, we received a notification, so set the flag
          await prefs.setBool('showNotification', true);
          log(
            "📬 ⚠️ [fetchLatestDataInBackground] Notification received but API call failed - setting dot flag anyway",
          );
        }
      } catch (e) {
        // Even if there's an error, we received a notification, so set the flag
        log(
          "❌ [fetchLatestDataInBackground] Error calling notification API: $e",
        );
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('showNotification', true);
          log(
            "📬 ⚠️ [fetchLatestDataInBackground] Set notification flag as fallback due to error",
          );
        } catch (prefError) {
          log("Error setting notification flag: $prefError");
        }
      }

      // Fetch complaints (can fail without affecting notification dot)
      try {
        final complaintsRepo = ComplaintsRepository();
        final filters = MyComplaintRequestModel(limit: 100);
        await complaintsRepo.getAllComplaints(token: token, filters: filters);
        log("📬 Fetched complaints in background");
      } catch (e) {
        log("Error fetching complaints in background: $e");
      }

      // Fetch wall of help messages (can fail without affecting notification dot)
      try {
        final wallOfHelpRepo = WallOfHelpRepository();
        await wallOfHelpRepo.getMyFinancialHelpRequestMessages(
          token: token,
          page: "1",
          pageSize: "124",
        );
        log("📬 Fetched wall of help messages in background");
      } catch (e) {
        log("Error fetching wall of help messages in background: $e");
      }

      // Fetch nearest member messages (can fail without affecting notification dot)
      try {
        final nearestMemberRepo = NearestMemberRepository();
        await nearestMemberRepo.getMyChats(token: token);
        log("📬 Fetched nearest member messages in background");
      } catch (e) {
        log("Error fetching nearest member messages in background: $e");
      }
    } catch (e) {
      log("Error in fetchLatestDataInBackground: $e");
      // Set flag as fallback - always show notification dot when notification is received
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showNotification', true);
        log("📬 Set notification flag as fallback due to error");
      } catch (prefError) {
        log("Error setting notification flag as fallback: $prefError");
      }
      _setDataRefreshFlag();
    }
  }

  /// Set flag to refresh data when app opens
  static Future<void> _setDataRefreshFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('needsDataRefresh', true);
      await prefs.setInt(
        'lastNotificationTime',
        DateTime.now().millisecondsSinceEpoch,
      );
      log("📬 Set data refresh flag");
    } catch (e) {
      log("Error setting data refresh flag: $e");
    }
  }

  /// Check if data needs to be refreshed and refresh if needed
  /// This is called when app RESUMES - the SAFE place to call APIs
  static Future<void> checkAndRefreshDataIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final needsRefresh = prefs.getBool('needsDataRefresh') ?? false;
      final showNotification = prefs.getBool('showNotification') ?? false;

      final navigatorContext = RouteManager.navigatorKey.currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) {
        log(
          "⚠️ [checkAndRefreshDataIfNeeded] Context not available, will retry later",
        );
        // Even if context is not available, try to refresh the ViewModel flag if we can
        // This helps when app is just starting and context might not be ready yet
        return;
      }

      // ANTI-FLASH LOGIC: Load notification dot from SharedPreferences FIRST (instant, no flash)
      // This is CRITICAL for chat notifications received while phone is in sleep
      // The background handler sets showNotification=true, and we must load it here
      try {
        final updateNotificationVm = navigatorContext
            .read<UpdateNotificationViewModel>();

        // STEP 1: Check SharedPreferences flag first
        // CRITICAL: Reload SharedPreferences to ensure we get the latest values
        // This is especially important when reading values set by background isolate
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        final showNotificationFlag = prefs.getBool('showNotification') ?? false;
        log(
          "📬 [checkAndRefreshDataIfNeeded] SharedPreferences showNotification flag: $showNotificationFlag",
        );

        // STEP 2: Optimistic update from SharedPreferences (instant, prevents flash)
        // This shows the dot immediately if a notification was received while app was closed/sleep
        // This is especially important for chat notifications (wallofhelp, nearestmember)
        await updateNotificationVm.refreshFromSharedPreferences();
        log(
          "📬 ✅ [checkAndRefreshDataIfNeeded] Notification dot loaded from SharedPreferences (instant, no flash)",
        );
        log(
          "📬 ✅ [checkAndRefreshDataIfNeeded] Current dot state: ${updateNotificationVm.showNotification}",
        );
        log(
          "📬 ✅ [checkAndRefreshDataIfNeeded] ℹ️ Dot will be verified when user opens notifications view",
        );

        // Don't verify with API automatically - this can hide the dot prematurely
        // The dot will be verified when user opens notifications view
        // This prevents the dot from disappearing before user sees the notification
      } catch (e) {
        log(
          "❌ [checkAndRefreshDataIfNeeded] Error loading notification dot: $e",
        );
        // Even on error, try to set the flag from SharedPreferences as fallback
        try {
          final prefs = await SharedPreferences.getInstance();
          // Reload to ensure we get the latest values
          await prefs.reload();
          final showNotificationFlag =
              prefs.getBool('showNotification') ?? false;
          if (showNotificationFlag) {
            final updateNotificationVm = navigatorContext
                .read<UpdateNotificationViewModel>();
            updateNotificationVm.showNotification = true;
            log(
              "📬 ✅ [checkAndRefreshDataIfNeeded] Fallback: Set dot to true from SharedPreferences",
            );
          }
        } catch (fallbackError) {
          log(
            "❌ [checkAndRefreshDataIfNeeded] Error in fallback: $fallbackError",
          );
        }
      }

      if (!needsRefresh && !showNotification) {
        // No other refresh needed, but we already refreshed the notification dot
        return;
      }

      // Clear flags first
      if (needsRefresh) {
        await prefs.setBool('needsDataRefresh', false);
      }

      log(
        "📬 [checkAndRefreshDataIfNeeded] App resumed - fetching notifications API",
      );

      // ✅ SAFE PLACE to call APIs - app is in foreground
      // Fetch notifications list API (but don't update dot automatically)
      // The dot will be verified when user opens notifications view
      try {
        final notificationVm = navigatorContext.read<NotificationViewModel>();
        await notificationVm.getNotifications();
        log(
          "📬 ✅ [checkAndRefreshDataIfNeeded] Notifications API called successfully",
        );
        log(
          "📬 ✅ [checkAndRefreshDataIfNeeded] ℹ️ Dot will be verified when user opens notifications view",
        );

        // Don't update dot automatically - this can hide it prematurely
        // The dot will be verified when user opens notifications view
      } catch (e) {
        log(
          "❌ [checkAndRefreshDataIfNeeded] Error calling notifications API: $e",
        );
      }

      // Also fetch other data (complaints, wall of help, nearest member)
      // This updates view models which will trigger GIF animation update
      fetchLatestDataOnNotification();
      log(
        "📬 ✅ [checkAndRefreshDataIfNeeded] All data refreshed on app resume",
      );
    } catch (e) {
      log("❌ [checkAndRefreshDataIfNeeded] Error: $e");
    }
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

  static woh.FinancialRequest _buildWallOfHelpRequest(
    String moduleId,
    Map<String, dynamic> data,
    BuildContext? context,
  ) {
    // Start with payload data if present
    woh.FinancialRequest request = woh.FinancialRequest(
      messageId: moduleId,
      sId:
          data['financialRequestId'] ??
          data['helpRequestId'] ??
          data['requestId'] ??
          data['sId'],
      name: data['userName'] ?? data['name'],
      description: data['reason'] ?? data['description'],
    );

    if (context == null) return request;

    // Enrich from cached chats if available
    try {
      final vm = context.read<FinancialHelpMessagesViewModel>();
      final chat = vm.myFinancialHelpChats.firstWhere(
        (c) => c.messageId == moduleId,
      );
      final user = chat.relatedUser;
      request = woh.FinancialRequest(
        sId: chat.financialHelpRequest,
        messageId: chat.messageId,
        name: user?.userName ?? request.name,
        description: user?.reason ?? request.description,
      );
    } catch (_) {
      // Provider not found or no match; keep payload data
    }

    return request;
  }

  static nm.PartyMember _buildNearestMember(
    String moduleId,
    String? userType,
    Map<String, dynamic> data,
    BuildContext? context,
  ) {
    // Start with payload data if present
    nm.PartyMember member = nm.PartyMember(
      name: data['userName'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      area: data['area'] as String?,
      city: data['city'] as String?,
      district: data['district'] as String?,
      state: data['state'] as String?,
      location: data['location'] is Map
          ? nm.Location.fromJson(
              (data['location'] as Map).cast<String, dynamic>(),
            )
          : null,
      partyMemberDetails: nm.PartyMemberDetails(
        sId: moduleId,
        type:
            (data['userType'] ??
                    data['recipientType'] ??
                    userType ??
                    'PartyMember')
                .toString(),
      ),
    );

    if (context == null) return member;

    // Enrich from cached chats if available
    try {
      final vm = context.read<MyMemberMessageViewModel>();
      final chat = vm.myChatsList.firstWhere(
        (c) => c.chatWith?.sId == moduleId,
      );
      final user = chat.chatWith;
      member = nm.PartyMember(
        sId: user?.sId ?? member.sId,
        name: user?.name ?? member.name,
        email: user?.email ?? member.email,
        phone: user?.phone ?? member.phone,
        avatar: user?.avatar ?? member.avatar,
        location: member.location,
        partyMemberDetails: nm.PartyMemberDetails(
          sId: moduleId,
          type:
              chat.chatWithType ??
              userType ??
              member.partyMemberDetails?.type ??
              "PartyMember",
        ),
      );
    } catch (_) {
      // Provider not found or no match; keep payload data
    }

    return member;
  }

  static complaint.Data _buildComplaint(
    String moduleId,
    Map<String, dynamic> data,
    BuildContext? context,
  ) {
    // Start with payload data if present
    complaint.Data complaintData = complaint.Data(
      sId:
          data['complaintId'] ??
          data['complaint_id'] ??
          data['requestId'] ??
          data['sId'] ??
          moduleId,
      threadId: data['threadId'] ?? data['thread_id'],
      status: data['status'] ?? 'pending',
      toMail: data['toMail'] ?? data['to_mail'],
      authorityName: data['authorityName'] ?? data['authority_name'],
    );

    if (context == null) return complaintData;

    // Enrich from cached complaints list if available
    try {
      final vm = context.read<ComplaintsViewModel>();
      final cachedComplaint = vm.complaintsList.firstWhere(
        (c) => c.sId == moduleId || c.threadId == moduleId,
      );
      // Use cached complaint data which has all the details
      complaintData = cachedComplaint;
    } catch (_) {
      // Provider not found or no match; keep payload data
    }

    return complaintData;
  }

  /// Generate meaningful title from notification data when title is missing
  static String? _generateTitleFromData(Map<String, dynamic> data) {
    try {
      final module = (data['module'] ?? '').toString().toLowerCase();
      final type = (data['type'] ?? '').toString().toLowerCase();
      final userName = data['userName'] ?? data['name'];

      // Generate title based on module/type
      if (module == 'wallofhelp' || module == 'financialhelp') {
        if (userName != null && userName.toString().trim().isNotEmpty) {
          return 'Wall of Help - $userName';
        }
        return 'Wall of Help';
      }

      if (module == 'nearestpartymember' || module == 'nearestmember') {
        if (userName != null && userName.toString().trim().isNotEmpty) {
          return 'Message from $userName';
        }
        return 'Nearest Member Message';
      }

      if (module == 'compliant' ||
          module == 'complaint' ||
          module == 'complaints') {
        return 'Complaint Update';
      }

      if (type == 'appointment') {
        return 'Appointment Notification';
      }

      // Try to use type as title if available
      if (type.isNotEmpty && type != 'general') {
        return type
            .split(' ')
            .map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1);
            })
            .join(' ');
      }

      return null;
    } catch (e) {
      log("Error generating title from data: $e");
      return null;
    }
  }

  /// Generate meaningful body from notification data when body is missing
  static String? _generateBodyFromData(Map<String, dynamic> data) {
    try {
      final module = (data['module'] ?? '').toString().toLowerCase();
      final type = (data['type'] ?? '').toString().toLowerCase();
      final userName = data['userName'] ?? data['name'];
      final reason = data['reason'] ?? data['description'];

      // Generate body based on module/type
      if (module == 'wallofhelp' || module == 'financialhelp') {
        if (reason != null && reason.toString().trim().isNotEmpty) {
          return reason.toString();
        }
        if (userName != null && userName.toString().trim().isNotEmpty) {
          return 'New message from $userName';
        }
        return 'You have a new financial help request';
      }

      if (module == 'nearestpartymember' || module == 'nearestmember') {
        if (userName != null && userName.toString().trim().isNotEmpty) {
          return 'You have a new message from $userName';
        }
        return 'You have a new message from a party member';
      }

      if (module == 'compliant' ||
          module == 'complaint' ||
          module == 'complaints') {
        final status = data['status'] ?? 'updated';
        return 'Your complaint has been $status';
      }

      if (type == 'appointment') {
        final status = data['status'] ?? 'updated';
        return 'Your appointment has been $status';
      }

      // Try to use description or reason if available
      final description = data['description'] ?? data['reason'];
      if (description != null && description.toString().trim().isNotEmpty) {
        return description.toString();
      }

      return null;
    } catch (e) {
      log("Error generating body from data: $e");
      return null;
    }
  }

  /// Generate unique notification ID from message data
  static int _generateNotificationId(RemoteMessage message) {
    try {
      final data = message.data;
      final notificationId = data['_id'] ?? 
          data['notificationId'] ?? 
          data['messageId'] ?? 
          data['id'] ??
          message.messageId;
      
      if (notificationId != null) {
        // Use hash of notification ID to create a consistent integer ID
        final hash = notificationId.hashCode;
        // Ensure positive ID (Android requires non-negative)
        return hash.abs() % 2147483647; // Max int32
      }
      
      // Fallback: use timestamp-based ID
      return DateTime.now().millisecondsSinceEpoch % 2147483647;
    } catch (e) {
      log("Error generating notification ID: $e");
      return DateTime.now().millisecondsSinceEpoch % 2147483647;
    }
  }

  /// Check if notification was already shown (deduplication)
  static Future<bool> _isNotificationAlreadyShown(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationId = _generateNotificationId(message);
      final shownNotifications = prefs.getStringList('shown_notification_ids') ?? [];
      
      // Check if this notification ID was already shown
      if (shownNotifications.contains(notificationId.toString())) {
        log("📬 ⚠️ Notification already shown (ID: $notificationId) - skipping duplicate");
        return true;
      }
      
      // Add to shown list
      shownNotifications.add(notificationId.toString());
      
      // Keep only last 1000 notification IDs to prevent storage bloat
      if (shownNotifications.length > 1000) {
        shownNotifications.removeRange(0, shownNotifications.length - 1000);
      }
      
      await prefs.setStringList('shown_notification_ids', shownNotifications);
      return false;
    } catch (e) {
      log("Error checking notification deduplication: $e");
      return false; // If check fails, allow notification to show
    }
  }

  /// Validate notification has meaningful content
  static bool _isValidNotification(RemoteMessage message) {
    try {
      final notification = message.notification;
      final data = message.data;
      
      // Check if notification has title or body
      final hasTitle = (notification?.title?.trim().isNotEmpty ?? false) ||
          (data['title']?.toString().trim().isNotEmpty ?? false);
      final hasBody = (notification?.body?.trim().isNotEmpty ?? false) ||
          (data['body']?.toString().trim().isNotEmpty ?? false) ||
          (data['message']?.toString().trim().isNotEmpty ?? false);
      
      // At least one of title or body must be present
      if (!hasTitle && !hasBody) {
        // Check if we can generate meaningful content
        final generatedTitle = _generateTitleFromData(data);
        final generatedBody = _generateBodyFromData(data);
        
        if (generatedTitle == null && generatedBody == null) {
          log("📬 ❌ Invalid notification: No title, body, or generatable content");
          return false;
        }
      }
      
      return true;
    } catch (e) {
      log("Error validating notification: $e");
      return true; // If validation fails, allow notification to show
    }
  }

  //display local notification
  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    // DEDUPLICATION: Check if notification was already shown
    final alreadyShown = await _isNotificationAlreadyShown(message);
    if (alreadyShown) {
      log("📬 ⚠️ Duplicate notification detected and prevented");
      return;
    }

    // VALIDATION: Check if notification has valid content
    if (!_isValidNotification(message)) {
      log("📬 ❌ Empty/invalid notification detected and prevented");
      return;
    }

    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    // Helper function to get non-empty string value
    String? _getNonEmptyString(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty ? null : str;
    }

    // Try to get title from multiple sources
    String title =
        _getNonEmptyString(notification?.title) ??
        _getNonEmptyString(data['title']) ??
        _generateTitleFromData(data) ??
        'SEVAK';

    // Try to get body from multiple sources
    String body =
        _getNonEmptyString(notification?.body) ??
        _getNonEmptyString(data['body']) ??
        _getNonEmptyString(data['message']) ??
        _generateBodyFromData(data) ??
        'New notification';

    // Final validation: Ensure title and body are not just fallback values
    // If both are fallback, it means the notification has no real content
    if (title == 'SEVAK' && body == 'New notification') {
      // Check if we have any meaningful data
      final hasModule = data['module'] != null && data['module'].toString().trim().isNotEmpty;
      final hasType = data['type'] != null && data['type'].toString().trim().isNotEmpty;
      
      if (!hasModule && !hasType) {
        log("📬 ❌ Notification has no meaningful content - preventing empty notification");
        return;
      }
    }

    // Generate unique notification ID
    final notificationId = _generateNotificationId(message);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'org.amunik.sevak',
      'SEVAK',
      channelDescription: 'Notification channel for SEVAK',
      priority: Priority.high,
      importance: Importance.high,
      // Use notification ID to prevent duplicates at OS level
      tag: notificationId.toString(),
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

    // Log notification details for debugging
    log("📬 Showing notification (ID: $notificationId) - Title: '$title', Body: '$body'");
    log(
      "   Notification object - title: '${notification?.title}', body: '${notification?.body}'",
    );
    log(
      "   Data payload - title: '${data['title']}', body: '${data['body']}', message: '${data['message']}'",
    );
    log("   Module: '${data['module']}', Type: '${data['type']}'");

    await flutterLocalNotificationPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(data),
    );

    // Persist "new notification" state for the badge
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showNotification', true);

    // BEST LOGIC: Update the in-app badge immediately when notification is shown
    final navigatorContext = RouteManager.navigatorKey.currentContext;
    if (navigatorContext != null && navigatorContext.mounted) {
      try {
        final updateNotificationVm = navigatorContext
            .read<UpdateNotificationViewModel>();
        // OPTIMISTIC UPDATE: Show dot immediately
        updateNotificationVm.showNotification = true;
        log("📬 ✅ Dot shown immediately when notification displayed");
        log("📬 ✅ Dot will be verified when user opens notifications view");

        // Don't verify with API automatically - this can hide the dot prematurely
        // The dot will be verified when user opens notifications view
        // This prevents the dot from disappearing before user sees the notification
      } catch (_) {
        // Provider not ready yet; will be refreshed when the notification page opens
        log("⚠️ UpdateNotificationViewModel not ready yet");
      }

      // Update chat icon by calling APIs when wallofhelp or nearestmember notifications are received
      _updateChatIconOnNotification(navigatorContext, data);
    }
  }

  // Update chat icon by calling respective APIs when wallofhelp or nearestmember notifications are received
  static Future<void> _updateChatIconOnNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      final module = (data['module'] ?? '').toString().toLowerCase();

      // Check if notification is related to wallofhelp
      if (module == 'wallofhelp') {
        try {
          final financialHelpVm = context
              .read<FinancialHelpMessagesViewModel>();
          // Call API to update unread count
          await financialHelpVm.getMyFinancialHelpRequestMessages();
          log("✅ Wall of Help unread count updated after notification");
        } catch (e) {
          log("Error updating Wall of Help unread count: $e");
        }
      }

      // Check if notification is related to nearestmember
      if (module == 'nearestpartymember' || module == 'nearestmember') {
        try {
          final nearestMemberVm = context.read<MyMemberMessageViewModel>();
          // Only call API if token is available
          if (nearestMemberVm.token != null &&
              nearestMemberVm.token!.isNotEmpty) {
            await nearestMemberVm.getAllChats();
            log("✅ Nearest Member unread count updated after notification");
          }
        } catch (e) {
          log("Error updating Nearest Member unread count: $e");
        }
      }

      // Check if notification is related to complaints (module: "compliant")
      if (module == 'compliant' ||
          module == 'complaint' ||
          module == 'complaints') {
        try {
          final complaintsVm = context.read<ComplaintsViewModel>();
          // Call API to update unread count
          await complaintsVm.getComplaints(
            showLoader: false,
            preserveSearch: true,
          );
          log("✅ Complaints unread count updated after notification");
        } catch (e) {
          log("Error updating Complaints unread count: $e");
        }
      }

      // The animation in indl_view.dart will automatically react to totalUnreadCount changes
      // via Consumer2 widget that watches both FinancialHelpMessagesViewModel and MyMemberMessageViewModel
    } catch (e) {
      log("Error updating chat icon on notification: $e");
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

  /// Initialize local notifications for background handler (public method)
  static Future<void> initializeLocalNotificationForBackground() async {
    await _initializeLocalNotification();
  }

  /// Show flutter notification in background handler (public method)
  static Future<void> showFlutterNotificationInBackground(
    RemoteMessage message,
  ) async {
    await _showFlutterNotification(message);
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

        try {
          if (response.payload != null && response.payload!.isNotEmpty) {
            final decoded = jsonDecode(response.payload!);
            if (decoded is Map<String, dynamic>) {
              _handleNavigationFromData(decoded);
            }
          }
        } catch (e) {
          log("Error handling notification tap: $e");
        }
      },
    );
  }

  // Handle notification that opened app from terminated state
  static Future<void> _getInitialNotification() async {
    try {
      RemoteMessage? message = await FirebaseMessaging.instance
          .getInitialMessage();
      if (message != null) {
        _handleNavigationFromMessage(message);
      }
    } catch (e) {
      log("Error getting initial notification: $e");
    }
  }

  static Future<void> _handleNavigationFromMessage(
    RemoteMessage message,
  ) async {
    await _handleNavigationFromData(message.data);
  }

  static bool _isNavigatorReady() =>
      RouteManager.navigatorKey.currentState?.mounted ?? false;

  static const Duration _navigatorPollInterval = Duration(milliseconds: 200);
  static const Duration _navigatorTimeout = Duration(seconds: 5);

  static Future<bool> _waitForNavigatorReady() async {
    final start = DateTime.now();
    while (!_isNavigatorReady()) {
      if (DateTime.now().difference(start) >= _navigatorTimeout) {
        return false;
      }
      await Future.delayed(_navigatorPollInterval);
    }
    return true;
  }

  static Future<void> _handleNavigationFromData(
    Map<String, dynamic> data,
  ) async {
    // Wait until navigator is ready (app resumed / built)
    final ready = await _waitForNavigatorReady();
    if (!ready) {
      log("Navigator not ready in time for notification tap");
      return;
    }

    try {
      final module = (data['module'] ?? '').toString().toLowerCase();
      final moduleId = data['moduleId'] ?? data['messageId'] ?? data['id'];
      if (moduleId == null || moduleId.toString().isEmpty) {
        // If the payload is missing required identifiers, fall back to the notifications list
        RouteManager.pushNamed(Routes.notificationsPage);
        return;
      }
      final navigatorContext = RouteManager.navigatorKey.currentContext;

      if (module == 'wallofhelp') {
        final request = _buildWallOfHelpRequest(
          moduleId.toString(),
          data,
          navigatorContext,
        );
        RouteManager.pushNamed(Routes.chatContributePage, arguments: request);
        return;
      }

      if (module == 'nearestpartymember') {
        final member = _buildNearestMember(
          moduleId.toString(),
          data['userType']?.toString(),
          data,
          navigatorContext,
        );
        RouteManager.pushNamed(Routes.chatMemberPage, arguments: member);
        return;
      }

      if (module == 'compliant' ||
          module == 'complaint' ||
          module == 'complaints') {
        final complaintData = _buildComplaint(
          moduleId.toString(),
          data,
          navigatorContext,
        );
        RouteManager.pushNamed(
          Routes.threadComplaintPage,
          arguments: complaintData,
        );
        return;
      }

      // Fallback: open notifications list so user can see the item even if module isn't mapped
      RouteManager.pushNamed(Routes.notificationsPage);
    } catch (e) {
      log("Error navigating from notification data: $e");
      // If navigation fails, direct user to notifications list as a safe fallback
      RouteManager.pushNamed(Routes.notificationsPage);
    }
  }
}
