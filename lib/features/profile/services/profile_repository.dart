import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/models/response/user_profile_model.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/auth/models/request/user_register_request_model.dart';

class ProfileRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<UserProfileModel>> getUserProfile({
    required String token,
  }) async {
    final response = await _network.get(
      path: URLs.getUserProfile,
      token: token,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: UserProfileModel.fromJson(response));
  }

  Future<RepoResponse<UserProfileModel>> updateUserProfile({
    required RequestRegisterModel data,
    required String token,
  }) async {
    final response = await _network.put(
      token: token,
      path: URLs.editUser,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: UserProfileModel.fromJson(response));
  }
}
