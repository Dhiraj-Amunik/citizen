import 'package:dio/dio.dart';
import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/complaints/model/request/reply_request_model.dart';
import 'package:inldsevak/features/complaints/model/request/request_authorities_model.dart';
import 'package:inldsevak/features/complaints/model/request/thread_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/add_complaints_model.dart';
import 'package:inldsevak/features/complaints/model/response/authorites_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/model/response/constituency_model.dart';
import 'package:inldsevak/features/complaints/model/response/reply_thread_model.dart';

class ComplaintsRepository {
  NetworkRequester network = NetworkRequester();

  Future<RepoResponse<AddComplaintsModel>> addComplaints({
    required FormData data,
    required String token,
  }) async {
    final response = await network.post(
      token: token,
      path: URLs.addComplaint,
      data: data,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: AddComplaintsModel.fromJson(response));
  }

  Future<RepoResponse<ComplaintsModel>> getAllComplaints({
    required String token,
  }) async {
    final response = await network.get(
      token: token,
      path: URLs.getComplaintByUserID,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ComplaintsModel.fromJson(response));
  }

  Future<RepoResponse<ComplaintsByThreadsModel>> getComplaintThread({
    required String? token,
    required ThreadRequestModel data,
  }) async {
    final response = await network.post(
      token: token,
      data: data.toJson(),
      path: URLs.getComplaintByThreadID,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ComplaintsByThreadsModel.fromJson(response));
  }

  Future<RepoResponse<ReplyThreadModel>> replyComplaints({
    required ReplyRequestModel data,
    required String? token,
  }) async {
    final response = await network.post(
      token: token,
      path: URLs.replyToComplaintByThreadID,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ReplyThreadModel.fromJson(response));
  }

  Future<RepoResponse<ComplaintDepatmentsModel>> getDepartments(
    String? token,
  ) async {
    final response = await network.get(token: token, path: URLs.getDepartments);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ComplaintDepatmentsModel.fromJson(response));
  }

  Future<RepoResponse<AuthoritiesModel>> getAuthorites({
    required RequestAuthoritiesModel data,
    required String? token,
  }) async {
    final response = await network.post(
      token: token,
      path: URLs.getAuthority,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: AuthoritiesModel.fromJson(response));
  }

  Future<RepoResponse<ConstituencyModel>> getConstituencies(
    String? token,
  ) async {
    final response = await network.get(
      token: token,
      path: URLs.getConstituencies,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ConstituencyModel.fromJson(response));
  }
}
