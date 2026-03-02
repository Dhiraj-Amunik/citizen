import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';
import 'package:inldsevak/features/notification/models/notification_history_model.dart';
import 'package:inldsevak/features/notification/models/notify_popup_model.dart';
import 'package:inldsevak/features/notification/models/mark_read_response.dart';

class NotificationRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<NotificationsModel>> getNotificationsApi({
    required String? token,
  }) async {
    final response = await _network.get(token: token, path: URLs.notifications);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: NotificationsModel.fromJson(response));
  }

  Future<RepoResponse<NotificationHistoryModel>> getNotificationHistoryApi({
    required String? token,
    required int page,
    required int limit,
  }) async {
    final response = await _network.get(
      token: token,
      path: "${URLs.notificationHistory}?page=$page&limit=$limit",
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: NotificationHistoryModel.fromJson(response));
  }

  Future<RepoResponse<NotifyPopupModel>> getNotifyPopupApi({
    required String? token,
  }) async {
    final response = await _network.get(
      token: token,
      path: URLs.getNotifyPopup,
      data: {}, // Important: API requires empty JSON body even for GET requests
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: NotifyPopupModel.fromJson(response));
  }

  Future<RepoResponse<MarkReadResponse>> markNotificationReadApi({
    required String? token,
    required Map<String, dynamic> data,
  }) async {
    final response = await _network.post(
      token: token,
      path: URLs.markNotificationRead,
      data: data,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: MarkReadResponse.fromJson(response));
  }
}
