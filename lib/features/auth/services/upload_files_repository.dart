import 'package:dio/dio.dart';
import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/models/response/upload_profile_pic_model.dart';
import 'package:inldsevak/core/utils/urls.dart';

class UploadFilesRepository {
  NetworkRequester network = NetworkRequester();

  Future<RepoResponse<UploadProfilePicModel>> uploadImage({
    required FormData data,
    required String token,
  }) async {
    final response = await network.post(
      path: URLs.uploadImage,
      data: data,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: UploadProfilePicModel.fromJson(response));
  }
   Future<RepoResponse<UploadProfilePicModel>> uploadMultipleImage({
    required FormData data,
  }) async {
    final response = await network.post(
      path: URLs.uploadMultipleImage,
      data: data,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: UploadProfilePicModel.fromJson(response));
  }
}
