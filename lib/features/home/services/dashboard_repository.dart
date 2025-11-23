import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/home/models/request/dashboard_request_model.dart';
import 'package:inldsevak/features/home/models/response/dashboard_response_model.dart';

class DashboardRepository {
  DashboardRepository();

  final NetworkRequester _networkRequester = NetworkRequester();

  Future<RepoResponse<DashboardResponseModel>> fetchDashboard({
    required String? token,
  }) async {
    final response = await _networkRequester.get(
      path: URLs.getDashboard,
      token: token,
    );

    if (response is APIException) {
      return RepoResponse(error: response);
    }

    return RepoResponse(
      data: DashboardResponseModel.fromJson(
        response as Map<String, dynamic>,
      ),
    );
  }

  Future<RepoResponse<DashboardResponseModel>> fetchUserDashboard({
    required String? token,
    required DashboardRequestModel model,
  }) async {
    final response = await _networkRequester.post(
      path: URLs.userDashboard,
      token: token,
      data: model.toJson(),
    );

    if (response is APIException) {
      return RepoResponse(error: response);
    }

    return RepoResponse(
      data: DashboardResponseModel.fromJson(
        response as Map<String, dynamic>,
      ),
    );
  }
}

