import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart';

class MlaService {
  final _network = NetworkRequester();

  Future<RepoResponse<MLADropdownModel>> getMLAsData(String? token) async {
    final response = await _network.get(path: URLs.userMLAs, token: token);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: MLADropdownModel.fromJson(response));
  }
}
