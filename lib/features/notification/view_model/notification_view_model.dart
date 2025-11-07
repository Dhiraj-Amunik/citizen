import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';
import 'package:inldsevak/features/notification/services/notification_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationViewModel extends BaseViewModel {
  @override
  Future<void> onInit() {
    getNotifications();
    return super.onInit();
  }

  final searchController = TextEditingController();

  List<Data> notificationsList = [];

  Future<void> getNotifications() async {
    notificationsList.clear();
    try {
      isLoading = true;
      final response = await NotificationRepository().getNotificationsApi(
        token: token,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        notificationsList.addAll(List.from(data as List));
        notifyListeners();
      }
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }
}

class UpdateNotificationViewModel extends ChangeNotifier {
  UpdateNotificationViewModel() {
    onStarted();
  }
  onStarted() async {
    final prefs = await SharedPreferences.getInstance();
    showNotification = prefs.getBool('showNotification') ?? false;
  }

  bool _showNotification = false;
  bool get showNotification => _showNotification;
  set showNotification(bool value) {
    _showNotification = value;
    notifyListeners();
  }

  disableNotificationIcon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showNotification', false);
  }
}
