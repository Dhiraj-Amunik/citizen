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
    
    if (response is APIException) {
      return RepoResponse(error: response);
    }
    
    // Debug: Print raw response
    print("═══════════════════════════════════════");
    print("📡 Nearest Member API Response:");
    print("Response type: ${response.runtimeType}");
    
    // Log location data from first member if available
    if (response is Map && response.containsKey('data')) {
      final data = response['data'];
      if (data is Map && data.containsKey('partyMember')) {
        final members = data['partyMember'];
        if (members is List && members.isNotEmpty) {
          print("First member location data: ${members[0]['location']}");
          print("First member address fields: address=${members[0]['address']}, city=${members[0]['city']}, district=${members[0]['district']}, state=${members[0]['state']}");
        }
      }
    }
    print("═══════════════════════════════════════");
    
    try {
      final parsedModel = NearestMembersModel.fromJson(response);
      print("Parsed model - responseCode: ${parsedModel.responseCode}");
      print("Parsed model - partyMember count: ${parsedModel.data?.partyMember?.length ?? 0}");
      
      // Log location data for each parsed member
      if (parsedModel.data?.partyMember != null) {
        for (var member in parsedModel.data!.partyMember!) {
          print("Member ${member.sId} - hasLocation: ${member.location != null}, hasAddress: ${member.address != null && member.address!.isNotEmpty}, hasCity: ${member.city != null && member.city!.isNotEmpty}");
        }
      }
      
      return RepoResponse(data: parsedModel);
    } catch (e, stackTrace) {
      print("Error parsing NearestMembersModel: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
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
    
    // Print raw response for debugging
    print("═══════════════════════════════════════");
    print("📬 getAllChats API Response:");
    print("Response type: ${response.runtimeType}");
    if (response is! APIException && response is Map) {
      print("Raw response: $response");
      print("Response keys: ${response.keys}");
      if (response.containsKey('data')) {
        final dataField = response['data'];
        print("Data field: $dataField");
        print("Data type: ${dataField.runtimeType}");
        if (dataField is List) {
          print("Data list length: ${dataField.length}");
        }
      }
    } else if (response is APIException) {
      print("Error response: $response");
    }
    print("═══════════════════════════════════════");
    
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: MyMembersChatModel.fromJson(response));
  }
}
