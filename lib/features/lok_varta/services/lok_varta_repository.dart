import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';

class LokVartaRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<LokVartaModel>> getLokVarta(
    String? token, {
    required RequestLokVartaModel model,
  }) async {
    final response = await _network.post(
      path: URLs.userLokVarta,
      token: token,
      data: model.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: LokVartaModel.fromJson(response));
  }
}
