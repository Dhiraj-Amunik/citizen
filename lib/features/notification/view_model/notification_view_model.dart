import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';
import 'package:inldsevak/features/notification/models/notify_popup_model.dart'; // Add this
import 'package:inldsevak/features/notification/services/notification_repository.dart';
import 'package:inldsevak/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationViewModel extends BaseViewModel {
  @override
  Future<void> onInit() async {
    // Don't call getNotifications here - let the view handle it after initialization
    await super.onInit();
  }

  final searchController = TextEditingController();

  List<Data> notificationsList = [];
  bool _hasInitialLoadCompleted = false;

  bool get hasInitialLoadCompleted => _hasInitialLoadCompleted;

  Future<void> getNotifications() async {
    try {
      // First, load stored background notifications (received when app was closed)
      await _loadStoredBackgroundNotifications();

      // Ensure token is available before making API call
      if (token == null || token!.isEmpty) {
        // Wait a bit for token to be loaded
        int retries = 0;
        while ((token == null || token!.isEmpty) && retries < 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          retries++;
        }

        // If still no token, return early (but keep stored notifications)
        if (token == null || token!.isEmpty) {
          debugPrint("Token not available for notifications API call");
          _hasInitialLoadCompleted = true;
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      isLoading = true;
      notifyListeners();

      final response = await NotificationRepository().getNotificationsApi(
        token: token,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data != null && data.isNotEmpty) {
          // Merge API notifications with stored background notifications
          await _mergeNotificationsWithStored(data);
        } else {
          // If no API data, keep stored notifications if any
          if (notificationsList.isEmpty) {
            await _loadStoredBackgroundNotifications();
          }
        }
        _hasInitialLoadCompleted = true;
        notifyListeners();

        // BEST LOGIC: Automatically update notification dot after loading notifications
        // This ensures dot is always in sync with actual data
        _updateNotificationDotAfterLoad();
      } else {
        // If response code is not 200, keep stored notifications if any
        if (notificationsList.isEmpty) {
          await _loadStoredBackgroundNotifications();
        }
        _hasInitialLoadCompleted = true;
        notifyListeners();

        // Still update dot even if API response is not 200
        _updateNotificationDotAfterLoad();
      }
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      // On error, still try to load stored notifications
      if (notificationsList.isEmpty) {
        await _loadStoredBackgroundNotifications();
      }
      _hasInitialLoadCompleted = true;

      // Update dot even on error (use stored notifications)
      _updateNotificationDotAfterLoad();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// BEST LOGIC: Update notification dot after notifications are loaded
  /// This is called automatically after getNotifications() completes
  void _updateNotificationDotAfterLoad() {
    try {
      // Get UpdateNotificationViewModel from the app context
      // We need to use a global key or find another way to access it
      // For now, we'll use a callback approach or direct update
      // The view will handle this via Consumer, but we can also trigger it here
      debugPrint(
        "📬 [NotificationViewModel] Notifications loaded: ${notificationsList.length} total",
      );

      // The dot will be updated by the view's Consumer or by calling updateDotFromNotificationsList
      // This method is here for future use if we need direct access to UpdateNotificationViewModel
    } catch (e) {
      debugPrint(
        "❌ [NotificationViewModel] Error in _updateNotificationDotAfterLoad: $e",
      );
    }
  }

  /// Load stored background notifications (received when app was closed)
  Future<void> _loadStoredBackgroundNotifications() async {
    try {
      final storedNotifications =
          await NotificationService.getStoredBackgroundNotifications();

      if (storedNotifications.isNotEmpty) {
        // Convert stored notifications to Data objects
        final storedDataList = storedNotifications
            .map((stored) {
              try {
                return Data.fromJson(stored);
              } catch (e) {
                debugPrint("Error parsing stored notification: $e");
                return null;
              }
            })
            .whereType<Data>()
            .toList();

        // Add to notifications list if not already present
        for (final storedData in storedDataList) {
          final exists = notificationsList.any((n) => n.sId == storedData.sId);
          if (!exists) {
            notificationsList.add(storedData);
          }
        }

        // Sort by createdAt (newest first)
        notificationsList.sort((a, b) {
          final aTime = a.createdAt ?? '';
          final bTime = b.createdAt ?? '';
          return bTime.compareTo(aTime);
        });

        debugPrint(
          "📬 Loaded ${storedDataList.length} stored background notifications",
        );
      }
    } catch (e) {
      debugPrint("Error loading stored background notifications: $e");
    }
  }

  /// Merge API notifications with stored background notifications
  Future<void> _mergeNotificationsWithStored(
    List<Data> apiNotifications,
  ) async {
    try {
      // Get stored notifications
      final storedNotifications =
          await NotificationService.getStoredBackgroundNotifications();

      // Create a map of API notification IDs for quick lookup
      final apiNotificationIds = apiNotifications
          .map((n) => n.sId)
          .whereType<String>()
          .toSet();

      // Add stored notifications that are not in API response
      for (final stored in storedNotifications) {
        try {
          final storedId = stored['_id'] as String?;
          if (storedId != null && !apiNotificationIds.contains(storedId)) {
            // This notification was received when app was closed and not yet in API
            final storedData = Data.fromJson(stored);
            apiNotifications.add(storedData);
          }
        } catch (e) {
          debugPrint("Error merging stored notification: $e");
        }
      }

      // Sort by createdAt (newest first)
      apiNotifications.sort((a, b) {
        final aTime = a.createdAt ?? '';
        final bTime = b.createdAt ?? '';
        return bTime.compareTo(aTime);
      });

      // Update notifications list
      notificationsList.clear();
      notificationsList.addAll(apiNotifications);

      // Clear stored notifications after merging (they're now in API)
      // Only clear if we successfully got API data
      if (apiNotifications.isNotEmpty) {
        await NotificationService.clearStoredBackgroundNotifications();
      }

      debugPrint("📬 Merged notifications: ${apiNotifications.length} total");
    } catch (e) {
      debugPrint("Error merging notifications: $e");
      // On error, just use API notifications
      notificationsList.clear();
      notificationsList.addAll(apiNotifications);
    }
  }

  // --- Popup Logic ---

  Future<NotifyPopupItem?> checkNotifyPopup() async {
    try {
      // Ensure token is available before making API call (important on app resume/cold starts)
      String? token = await SessionController.instance.getToken();
      if (token == null || token.isEmpty) {
        log("📬 [checkNotifyPopup] Token not found yet, waiting briefly...");
        int retries = 0;
        while ((token == null || token.isEmpty) && retries < 10) {
          await Future.delayed(const Duration(milliseconds: 300));
          token = await SessionController.instance.getToken();
          retries++;
        }
      }

      if (token == null || token.isEmpty) {
        log("📬 [checkNotifyPopup] ❌ FAILED - No token after waiting");
        return null;
      }

      log(
        "📬 [checkNotifyPopup] Fetching notify popup from API with valid token...",
      );
      final response = await NotificationRepository().getNotifyPopupApi(
        token: token,
      );

      if (response.data?.responseCode == 200) {
        final messages = response.data?.data;
        log(
          "📬 [checkNotifyPopup] Found ${messages?.length ?? 0} active popup items",
        );
        if (messages != null && messages.isNotEmpty) {
          // Return the first message as popup
          return messages.first;
        }
      } else {
        log(
          "📬 [checkNotifyPopup] API returned error or non-200 code: ${response.data?.responseCode}",
        );
      }
    } catch (e) {
      log("❌ [checkNotifyPopup] Error checking notify popup: $e");
    }
    return null;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = await SessionController.instance.getToken();
      await NotificationRepository().markNotificationReadApi(
        token: token,
        data: {
          "notificationId": notificationId,
          "notificationIds": [notificationId],
        },
      );
      // Update local unread count
      final index = notificationsList.indexWhere(
        (n) => n.sId == notificationId,
      );
      if (index != -1) {
        notificationsList[index].read = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      final token = await SessionController.instance.getToken();
      await NotificationRepository().markNotificationReadApi(
        token: token,
        data: {"markAll": true},
      );
      // Also update local unread count or refresh list if needed
      // Ideally getNotifications should be called or manually update list status
      for (var n in notificationsList) {
        n.read = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error marking notifications as read: $e");
    }
  }
}

class UpdateNotificationViewModel extends ChangeNotifier {
  UpdateNotificationViewModel() {
    // Initialize asynchronously - don't block constructor
    onStarted();
  }

  onStarted() async {
    // First load from SharedPreferences (optimistic approach)
    await refreshFromSharedPreferences();
    // Don't verify with API immediately - this can hide the dot prematurely
    // The dot will be verified when user opens notifications view or when app resumes
    // This prevents the dot from disappearing before user sees the notification
    debugPrint(
      "📬 [UpdateNotificationViewModel] Initialized with flag: $_showNotification (from SharedPreferences)",
    );
    debugPrint(
      "📬 [UpdateNotificationViewModel] ℹ️ Dot will be verified when user opens notifications view",
    );
  }

  bool _showNotification = false;
  bool get showNotification => _showNotification;
  set showNotification(bool value) {
    if (_showNotification != value) {
      _showNotification = value;
      notifyListeners();
      debugPrint("📬 [UpdateNotificationViewModel] Flag changed to: $value");
    }
  }

  /// BEST METHOD: Check for unread notifications by calling the API
  /// This is the most reliable way to determine if there are unread notifications
  Future<void> checkUnreadNotificationsFromAPI() async {
    try {
      // Get token
      final token = await SessionController.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint(
          "⚠️ [UpdateNotificationViewModel] No token available for API check",
        );
        return;
      }

      // Call notifications API
      final response = await NotificationRepository().getNotificationsApi(
        token: token,
      );

      if (response.data?.responseCode == 200) {
        final notifications = response.data?.data ?? [];

        // Check if there are any unread notifications
        // A notification is unread if read == false or read == null
        final hasUnreadNotifications = notifications.any((notification) {
          return notification.read == false || notification.read == null;
        });

        // Update flag based on API response
        if (_showNotification != hasUnreadNotifications) {
          _showNotification = hasUnreadNotifications;
          notifyListeners();
          debugPrint(
            "📬 [UpdateNotificationViewModel] ✅ API check: Found ${notifications.length} notifications, ${hasUnreadNotifications ? 'HAS' : 'NO'} unread - dot ${hasUnreadNotifications ? 'SHOWN' : 'HIDDEN'}",
          );
        } else {
          debugPrint(
            "📬 [UpdateNotificationViewModel] API check: Flag already correct (${hasUnreadNotifications ? 'HAS' : 'NO'} unread)",
          );
        }

        // Also update SharedPreferences to keep it in sync
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showNotification', hasUnreadNotifications);
      } else {
        debugPrint(
          "⚠️ [UpdateNotificationViewModel] API check failed: ${response.error?.message}",
        );
      }
    } catch (e) {
      debugPrint(
        "❌ [UpdateNotificationViewModel] Error checking unread notifications from API: $e",
      );
    }
  }

  /// Refresh the notification flag from SharedPreferences (fallback method)
  /// This should be called when app resumes to ensure flag is synced
  /// Always updates the flag to ensure it reflects the latest state from SharedPreferences
  Future<void> refreshFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // CRITICAL: Reload SharedPreferences to ensure we get the latest values
      // This is especially important when reading values set by background isolate
      await prefs.reload();

      final flagValue = prefs.getBool('showNotification') ?? false;
      // Always update to ensure sync, even if value appears the same
      // This is important because the ViewModel might initialize before SharedPreferences is ready
      // or when app resumes from sleep, the flag might have been set by background handler
      _showNotification = flagValue;
      notifyListeners();
      debugPrint(
        "📬 [UpdateNotificationViewModel] Refreshed flag from SharedPreferences: $flagValue",
      );
    } catch (e) {
      debugPrint(
        "❌ [UpdateNotificationViewModel] Error refreshing from SharedPreferences: $e",
      );
    }
  }

  /// Update notification dot based on already loaded notifications list
  /// This is more efficient than calling API again when notifications are already loaded
  /// This should ONLY be called from the notifications view when user opens it
  /// NOTE: This method should NOT be called if the dot was already cleared on view open
  void updateDotFromNotificationsList(List<Data> notifications) {
    try {
      // Check if there are any unread notifications
      // A notification is unread if read == false or read == null
      final hasUnreadNotifications = notifications.any((notification) {
        return notification.read == false || notification.read == null;
      });

      // CRITICAL: Only update if the flag is currently true
      // If it was cleared (false), don't override it - user has seen the notifications
      // This prevents the dot from reappearing after being cleared on view open
      if (_showNotification) {
        // Only update if flag is currently true (hasn't been cleared)
        _showNotification = hasUnreadNotifications;
        notifyListeners();
        debugPrint(
          "📬 [UpdateNotificationViewModel] ✅ Updated from list: ${notifications.length} notifications, ${hasUnreadNotifications ? 'HAS' : 'NO'} unread - dot ${hasUnreadNotifications ? 'SHOWN' : 'HIDDEN'}",
        );

        // Also update SharedPreferences to keep it in sync
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('showNotification', hasUnreadNotifications);
        });
      } else {
        // Flag was cleared (false) - don't override it
        debugPrint(
          "📬 [UpdateNotificationViewModel] ⚠️ Skipping update - dot was cleared on view open (${notifications.length} notifications, ${hasUnreadNotifications ? 'HAS' : 'NO'} unread)",
        );
      }
    } catch (e) {
      debugPrint(
        "❌ [UpdateNotificationViewModel] Error updating dot from notifications list: $e",
      );
    }
  }

  disableNotificationIcon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showNotification', false);
    // Update local state immediately
    _showNotification = false;
    notifyListeners();
    debugPrint("📬 [UpdateNotificationViewModel] Notification icon disabled");
  }
}
