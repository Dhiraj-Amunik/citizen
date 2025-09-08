import 'package:dio/dio.dart';
import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/models/response/upload_profile_pic_model.dart';
import 'package:inldsevak/core/utils/urls.dart';

class UploadImageRepository {
  final _network = NetworkRequester();
  Future<RepoResponse<UploadProfilePicModel>> uploadPicture({
    required FormData data,
    required String token,
  }) async {
    final response = await _network.post(
      token: token,
      path: URLs.uploadImage,
      data: data,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: UploadProfilePicModel.fromJson(response));
  }
}
