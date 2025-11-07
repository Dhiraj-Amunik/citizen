import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';

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
}
