import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/donated_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/help_message_model.dart';
import 'package:inldsevak/core/models/request/pagination_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/reply_help_message_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_donate_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_finanical_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_help_messages_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/woh_pagination_model.dart';
import 'package:inldsevak/features/surveys/model/success_model.dart';

class WallOfHelpRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<WallOfHelpModel>> getUsersWallOFHelp({
    String? token,
    WOHPaginationModel? model,
  }) async {
    final response = await _network.post(
      path: URLs.getUserWallOFHelpData,
      token: token,
      data: model?.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: WallOfHelpModel.fromJson(response));
  }

  Future<RepoResponse<WallOfHelpModel>> getMyWallOFHelp({
    String? token,
    PaginationModel? model,
  }) async {
    final response = await _network.post(
      path: URLs.getMyWallOfHelpLists,
      token: token,
      data: model?.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: WallOfHelpModel.fromJson(response));
  }

  Future<RepoResponse<SuccessModel>> createFinancialHelp({
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
        : RepoResponse(data: SuccessModel.fromJson(response));
  }

  Future<RepoResponse<SuccessModel>> updateFinancialHelp({
    required String? token,
    required RequestFinancialHelpModel model,
  }) async {
    final response = await _network.post(
      path: URLs.updateFinancialHelp,
      data: model.toJson(),
      token: token,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: SuccessModel.fromJson(response));
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

  Future<RepoResponse<TypesOFHelpModel>> getHelpsDD(String? token) async {
    final response = await _network.get(
      path: URLs.getTypesOfHelpsDD,
      token: token,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: TypesOFHelpModel.fromJson(response));
  }

  Future<RepoResponse<PreferredWaysModel>> getPreferredWaysDD(
    String? token,
  ) async {
    final response = await _network.get(
      path: URLs.getPreferredWaysDD,
      token: token,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: PreferredWaysModel.fromJson(response));
  }

  Future<RepoResponse<HelpMessagesModel>> getMessages({
    required String? token,
    required String? id,
  }) async {
    final response = await _network.post(
      path: URLs.getFinancialMessages,
      token: token,
      data: {"messageId": id},
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: HelpMessagesModel.fromJson(response));
  }

  Future<RepoResponse<ReplyHelpMessagesModel>> replyMessage({
    String? token,
    required RequestHelpMessageModel model,
  }) async {
    final response = await _network.post(
      path: URLs.replyFinancialMessages,
      token: token,
      data: model.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ReplyHelpMessagesModel.fromJson(response));
  }

  Future<RepoResponse<SuccessModel>> closeFinancialHelp({
    String? token,
    required String id,
  }) async {
    final response = await _network.post(
      path: URLs.completeMyFinancialHelp,
      token: token,
      data: {
        "requestId": id,
        "type": "complete", // API expects type field with enum value "complete" for closing/completing requests
      },
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: SuccessModel.fromJson(response));
  }
}
