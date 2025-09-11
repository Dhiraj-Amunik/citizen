import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/donated_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/financial_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_donate_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_finanical_help_model.dart';
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

  Future<RepoResponse<FinancialHelpModel>> createFinancialHelp({
    required String? token,
    required RequestFinancialHelpModel model,
  }) async {
    final response = await _network.post(
      path: URLs.requestFinancialHelp,
      data: model.toJson(),
      token: token,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: FinancialHelpModel.fromJson(response));
  }

  Future<RepoResponse<DonatedModel>> donateToHelpRequest({
    required String? token,
    required RequestDonateHelpModel model,
  }) async {
    final response = await _network.post(
      path: URLs.donateToHelpRequest,
      data: model.toJson(),
      token: token,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: DonatedModel.fromJson(response));
  }
}
