import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/auth/models/request/validate_otp_request_model.dart';
import 'package:inldsevak/features/auth/models/response/otp_response_model.dart';

class AuthRepository {
  NetworkRequester network = NetworkRequester();

  //login
  Future<RepoResponse<OTPResponseModel>> generateOTP(
    OtpRequestModel data,
  ) async {
    final response = await network.post(
      path: URLs.generateOTP,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: OTPResponseModel.fromJson(response));
  }

  //login
  Future<RepoResponse<OTPResponseModel>> validateOTP(
    OtpRequestModel data,
  ) async {
    final response = await network.post(
      path: URLs.verifyOTP,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: OTPResponseModel.fromJson(response));
  }

 
}
