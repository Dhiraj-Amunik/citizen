import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/notification/models/notification_history_model.dart';
import 'package:inldsevak/features/notification/services/notification_repository.dart';
import 'package:inldsevak/notification_service.dart';

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

          // Check if any unread notification is of type 'custom' to trigger popup instantly
          final hasCustomNotification = (data.notifications ?? []).any(
            (n) =>
                n.type?.toLowerCase() == 'custom' &&
                (n.read == false || n.read == null),
          );

          if (hasCustomNotification) {
            NotificationService.triggerPopupIfAvailable();
          }

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
