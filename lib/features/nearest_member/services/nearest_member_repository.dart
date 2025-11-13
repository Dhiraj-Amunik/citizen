import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/nearest_member/model/member_messages_model.dart';
import 'package:inldsevak/features/nearest_member/model/my_location_request_model.dart';
import 'package:inldsevak/features/nearest_member/model/my_member_chat_model.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/nearest_member/model/request_member_message_model.dart';
import 'package:inldsevak/features/surveys/model/success_model.dart';

class NearestMemberRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<NearestMembersModel>> getNearestMember(
    String? token, {
    required MyCurrentLocationRequestModel model,
  }) async {
    final response = await _network.post(
      path: URLs.getNearestMembers,
      token: token,
      data: model.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: NearestMembersModel.fromJson(response));
  }

  Future<RepoResponse<MemberMessagesModel>> getMessages({
    required String? token,
    required String? id,
    required String? type,
  }) async {
    final response = await _network.post(
      path: URLs.getNearestMemberMessages,
      token: token,
      data: {"otherPerson": id, "recipientType": type},
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: MemberMessagesModel.fromJson(response));
  }

  Future<RepoResponse<SuccessModel>> replyMessage({
    String? token,
    required RequestMemberMessageModel model,
  }) async {
    final response = await _network.post(
      path: URLs.postNearestMemberMessage,
      token: token,
      data: model.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: SuccessModel.fromJson(response));
  }

   Future<RepoResponse<MyMembersChatModel>> getMyChats({
    required String? token,
  }) async {
    final response = await _network.get(
      path: URLs.getMyMembersChats,
      token: token,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: MyMembersChatModel.fromJson(response));
  }
}
