import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/auth/models/request/user_register_request_model.dart';
import 'package:inldsevak/features/auth/models/response/user_profile_response_model.dart';

class UserProfileRepository {
  NetworkRequester network = NetworkRequester();

  Future<RepoResponse<UserProfileResponseModel>> userRegister({
    required RequestRegisterModel data,
    required String token,
  }) async {
    final response = await network.post(
      token: token,
      path: URLs.userRegister,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: UserProfileResponseModel.fromJson(response));
  }

  // Future<RepoResponse<UploadProfilePicModel>> uploadUserPicture({
  //   required FormData data,
  //   required String token,
  // }) async {
  //   final response = await network.post(
  //     token: token,
  //     path: URLs.uploadProfilePic,
  //     data: data,
  //   );

  //   return response is APIException
  //       ? RepoResponse(error: response)
  //       : RepoResponse(data: UploadProfilePicModel.fromJson(response));
  // }
}
