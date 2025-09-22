import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/common_fields/model/request_parliment_id_model.dart';
import 'package:inldsevak/features/common_fields/model/request_pincode_model.dart';


class ConstituenciesRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<ConstituencyModel>> getParliamentaryConstituencies({
    String? token,
    required RequestPincodeModel model,
  }) async {
    final response = await _network.post(
      token: token,
      path: URLs.getParliamentaryConstituency,
      data: model.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ConstituencyModel.fromJson(response));
  }

  Future<RepoResponse<ConstituencyModel>> getAssemblyConstituencies({
    String? token,
    required RequestParlimentIdModel model,
  }) async {
    final response = await _network.post(
      token: token,
      path: URLs.getAssemblyConstituency,
      data: model.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ConstituencyModel.fromJson(response));
  }
}
