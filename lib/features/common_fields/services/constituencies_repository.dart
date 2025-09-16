import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/common_fields/model/request_pincode_model.dart';
import 'package:inldsevak/features/complaints/model/response/constituency_model.dart';

class ConstituenciesRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<ConstituencyModel>> getPincodeConstituencies({
    String? token,
    required RequestPincodeModel model,
  }) async {
    final response = await _network.post(
      token: token,
      path: URLs.getPincodeConstituencies,
      data: model.toJson()
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ConstituencyModel.fromJson(response));
  }
}
