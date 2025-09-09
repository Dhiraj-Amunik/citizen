import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/party_member/model/request/party_member_request_model.dart';
import 'package:inldsevak/features/party_member/model/request/request_member_details.dart';
import 'package:inldsevak/features/party_member/model/response/parties_model.dart';
import 'package:inldsevak/features/party_member/model/response/party_member_details_model.dart';
import 'package:inldsevak/features/party_member/model/response/party_member_reponse_model.dart';

class PartyMemberRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<PartyMemberDetailsModel>> getUserDetails({
    required RequestMemberDetails data,
    required String token,
  }) async {
    final response = await _network.post(
      token: token,
      path: URLs.getUserDetails,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: PartyMemberDetailsModel.fromJson(response));
  }

  Future<RepoResponse<PartyMemberResponseModel>> createPartyMember({
    required PartyMemberRequestModel data,
    required String token,
  }) async {
    final response = await _network.post(
      token: token,
      path: URLs.becomePartyMember,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: PartyMemberResponseModel.fromJson(response));
  }

  Future<RepoResponse<PartiesModel>> getParties(String? token) async {
    final response = await _network.get(path: URLs.getParties, token: token);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: PartiesModel.fromJson(response));
  }
}
