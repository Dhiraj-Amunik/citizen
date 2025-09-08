import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart';

class WallOfHelpRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<WallOfHelpModel>> getWallOFHelp(String? token) async {
    final response = await _network.post(
      path: URLs.getUserWallOFHelpData,
      token: token,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: WallOfHelpModel.fromJson(response));
  }
}
