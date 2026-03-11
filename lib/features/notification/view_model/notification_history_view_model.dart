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

          // ── Robust Comparison Logic ────────────────────────────────────────
          // We compare the total count and the latest ID to detect new items
          final prefs = await SharedPreferences.getInstance();
          final currentTotal = data.pagination?.total ?? 0;
          final lastTotal = prefs.getInt('last_known_total_count') ?? 0;
          
          // Find the latest unread announcement/custom notification
          final latestUnread = (data.notifications ?? []).firstWhere(
            (n) => (n.read == false || n.read == null) && 
                   (n.type?.toLowerCase() == 'custom' || 
                    n.module?.toLowerCase() == 'custom' || 
                    n.module?.toLowerCase() == 'announcement' ||
                    n.module?.toLowerCase() == 'official_announcement'),
            orElse: () => NotificationItem(),
          );

          if (latestUnread.id != null) {
            final lastSeenId = prefs.getString('last_seen_announcement_id');
            
            // Trigger if:
            // 1. Total count increased (New notification arrived)
            // 2. OR the latest ID is different from what we last handled
            if (currentTotal > lastTotal || latestUnread.id != lastSeenId) {
              debugPrint("📬 [HistoryVM] New unread detected (ID: ${latestUnread.id})");
              
              final popupItem = NotifyPopupItem(
                id: latestUnread.id,
                title: latestUnread.title,
                message: latestUnread.message,
                image: latestUnread.image,
                type: latestUnread.type,
                module: latestUnread.module,
                createdAt: latestUnread.createdAt,
              );

              // Trigger popup (this will show the dialog)
              NotificationService.triggerPopupIfAvailable(pushItem: popupItem);
              
              // Persist current state
              await prefs.setString('last_seen_announcement_id', latestUnread.id!);
            }
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
