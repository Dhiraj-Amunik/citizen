import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/auth/models/response/otp_response_model.dart';
import 'package:inldsevak/features/volunter/models/response/volunteer_analytics_response_model.dart';

class VolunteerRepository {
  VolunteerRepository();

  final NetworkRequester _networkRequester = NetworkRequester();

  Future<RepoResponse<VolunteerAnalyticsResponseModel>>
      getVolunteerAnalytics({
    required String? token,
  }) async {
    final response = await _networkRequester.get(
      path: URLs.getVolunteerAnalytics,
      token: token,
    );

    if (response is APIException) {
      return RepoResponse(error: response);
    }

    return RepoResponse(
      data: VolunteerAnalyticsResponseModel.fromJson(
        response as Map<String, dynamic>,
      ),
    );
  }

  Future<RepoResponse<OTPResponseModel>> attendEvent({
    required String? token,
    required String eventId,
  }) async {
    final response = await _networkRequester.post(
      path: URLs.attendEvent,
      data: {'eventId': eventId},
      token: token,
    );

    if (response is APIException) {
      return RepoResponse(error: response);
    }

    return RepoResponse(
      data: OTPResponseModel.fromJson(
        response as Map<String, dynamic>,
      ),
    );
  }
}

