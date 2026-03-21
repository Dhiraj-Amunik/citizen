import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/notification/models/notification_history_model.dart';
import 'package:inldsevak/features/notification/services/notification_repository.dart';
import 'package:inldsevak/notification_service.dart';
import 'package:inldsevak/features/notification/models/notify_popup_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHistoryViewModel extends BaseViewModel {
  List<NotificationItem> notifications = [];
  Pagination? pagination;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<void> onInit() async {
    await super.onInit();
    await getHistory(isRefresh: true);
  }

  Future<void> getHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      if (isLoading) return; // Prevent double-fetch if already loading
      _currentPage = 1;
      _hasMoreData = true;
      notifications.clear();
      isLoading = true;
      notifyListeners();
    } else {
      if (!_hasMoreData || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final response = await NotificationRepository().getNotificationHistoryApi(
        token: token,
        page: _currentPage,
        limit: _pageSize,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data != null) {
          if (isRefresh) {
            notifications = data.notifications ?? [];
          } else {
            notifications.addAll(data.notifications ?? []);
          }

          // ✅ IMPROVED: Robust detection of custom/announcement notifications
          // Look for ANY custom/announcement notification (not just unread)
          // This ensures we catch notifications even if read status is incorrect
          final prefs = await SharedPreferences.getInstance();
          final currentTotal = data.pagination?.total ?? 0;
          final lastTotal = prefs.getInt('last_known_total_count') ?? 0;
          
          debugPrint("📬 [HistoryVM] Total notifications: $currentTotal (last known: $lastTotal)");
          
          // Find the FIRST (latest) custom/announcement notification
          // Don't filter by read status - show it regardless
          final customNotifications = (data.notifications ?? [])
              .where((n) => 
                  n.type?.toLowerCase() == 'custom' || 
                  n.module?.toLowerCase() == 'custom' || 
                  n.type?.toLowerCase() == 'announcement' ||
                  n.module?.toLowerCase() == 'announcement' ||
                  n.module?.toLowerCase() == 'official_announcement')
              .toList();

          debugPrint("📬 [HistoryVM] Found ${customNotifications.length} custom/announcement notifications");

          if (customNotifications.isNotEmpty) {
            final latestNotification = customNotifications.first;
            final lastSeenId = prefs.getString('last_seen_announcement_id');
            
            debugPrint("📬 [HistoryVM] Latest custom notification ID: ${latestNotification.id}, Last seen: $lastSeenId");
            
            // Trigger popup if:
            // 1. Total count increased (new notification arrived)
            // 2. OR the latest ID is different from what we last handled
            // 3. OR this is the first time checking (lastTotal was 0)
            if (currentTotal > lastTotal || latestNotification.id != lastSeenId || lastTotal == 0) {
              debugPrint("📬 [HistoryVM] ✅ Showing popup for custom notification (ID: ${latestNotification.id}, Title: ${latestNotification.title})");
              
              final popupItem = NotifyPopupItem(
                id: latestNotification.id,
                title: latestNotification.title,
                message: latestNotification.message,
                image: latestNotification.image,
                type: latestNotification.type,
                module: latestNotification.module,
                createdAt: latestNotification.createdAt,
              );

              // ✅ Mark that popup is being shown from history (for kill state skip logic)
              await prefs.setBool('popup_shown_from_dashboard', true);

              // ✅ Small delay to ensure UI is ready before showing popup
              Future.delayed(const Duration(milliseconds: 300), () {
                NotificationService.triggerPopupIfAvailable(pushItem: popupItem);
              });
              
              // Persist current state
              await prefs.setString('last_seen_announcement_id', latestNotification.id!);
            } else {
              debugPrint("📬 [HistoryVM] Skip popup - not new (count check: $currentTotal > $lastTotal, id check: ${latestNotification.id} != $lastSeenId)");
            }
          } else {
            debugPrint("📬 [HistoryVM] No custom/announcement notifications found");
          }
          
          // Always update the total count reference
          await prefs.setInt('last_known_total_count', currentTotal);
          // ──────────────────────────────────────────────────────────────────

          pagination = data.pagination;

          if (pagination != null) {
            _hasMoreData = _currentPage < (pagination?.totalPages ?? 1);
            if (_hasMoreData) {
              _currentPage++;
            }
          } else {
            _hasMoreData = false;
          }
        }
      } else {
        // Handle error if needed
      }
    } catch (e) {
      debugPrint("Error fetching notification history: $e");
    } finally {
      isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
