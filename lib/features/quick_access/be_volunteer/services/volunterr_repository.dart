import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/auth/models/response/otp_response_model.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/model/request_volunteer_model.dart';

class VolunterrRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<OTPResponseModel>> createVolunteer(
    RequestVolunteerModel data,
    String? token,
  ) async {
    final response = await _network.post(
      path: URLs.createVolunter,
      data: data.toJson(),
      token: token,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: OTPResponseModel.fromJson(response));
  }
}
