import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/complaints/model/request/complaint_by_id_request_model.dart';
import 'package:inldsevak/features/complaints/model/request/complaint_case_request_model.dart';
import 'package:inldsevak/features/complaints/model/request/my_complaint_request_model.dart';
import 'package:inldsevak/features/complaints/model/request/request_authorities_model.dart';
import 'package:inldsevak/features/complaints/model/request/thread_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/add_complaints_model.dart';
import 'package:inldsevak/features/complaints/model/response/authorites_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_case_response_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
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

    // Check if response is an error
    if (response is APIException) {
      return RepoResponse(error: response);
    }

    // Check if response has error responseCode (400, 500, etc.)
    if (response is Map<String, dynamic>) {
      final responseCode = response['responseCode'];
      if (responseCode != null && responseCode != 200) {
        // Extract error message from response
        final errorMessage = response['message'] ?? response['error'] ?? 'Failed to lodge complaint';
        return RepoResponse(
          error: APIException(message: errorMessage.toString()),
        );
      }
      
      // If responseCode == 200, extract the data field and parse it
      // API response format: {responseCode: 200, message: "...", data: {...}}
      // AddComplaintsModel expects: {success: true, threadId: "...", messageId: "..."}
      // The data field contains threadId, so we need to extract it
      if (responseCode == 200 && response['data'] != null) {
        final dataMap = response['data'] as Map<String, dynamic>;
        // Create a model-compatible map with success and threadId
        final modelData = {
          'success': true,
          'threadId': dataMap['threadId'],
          'messageId': dataMap['messages'] != null && (dataMap['messages'] as List).isNotEmpty
              ? (dataMap['messages'] as List).first['messageId']
              : dataMap['threadId'], // Fallback to threadId if messageId not found
        };
        try {
          return RepoResponse(data: AddComplaintsModel.fromJson(modelData));
        } catch (e) {
          debugPrint("Error parsing AddComplaintsModel: $e");
          // If parsing fails, still return success since responseCode is 200
          return RepoResponse(
            data: AddComplaintsModel(
              success: true,
              threadId: dataMap['threadId']?.toString(),
              messageId: dataMap['threadId']?.toString(),
            ),
          );
        }
      }
    }

    // Try to parse as success response (fallback for old format)
    try {
      return RepoResponse(data: AddComplaintsModel.fromJson(response));
    } catch (e) {
      // If parsing fails, check if it's an error response
      if (response is Map<String, dynamic>) {
        final errorMessage = response['message'] ?? response['error'] ?? 'Failed to lodge complaint';
        return RepoResponse(
          error: APIException(message: errorMessage.toString()),
        );
      }
      return RepoResponse(
        error: APIException(message: 'Failed to parse server response'),
      );
    }
  }

  Future<RepoResponse<ReplyThreadModel>> raiseComplaint({
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
        : RepoResponse(data: ReplyThreadModel.fromJson(response));
  }

  Future<RepoResponse<ComplaintsModel>> getAllComplaints({
    required String token,
   required MyComplaintRequestModel filters,
  }) async {
    final response = await network.post(
      token: token,
      path: URLs.getComplaintByUserID,
      data: filters.toJson(),
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

  Future<RepoResponse<ComplaintsByThreadsModel>> getComplaintByThreadId({
    required String? token,
    required ComplaintByIdRequestModel data,
  }) async {
    final response = await network.post(
      token: token,
      data: data.toJson(),
      path: URLs.getComplaintByThreadId,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: ComplaintsByThreadsModel.fromJson(response));
  }

  Future<RepoResponse<ReplyThreadModel>> replyComplaints({
    required FormData data,
    required String? token,
  }) async {
    final response = await network.post(
      token: token,
      path: URLs.addComplaint,
      data: data,
    );

    // Check if response is an error
    if (response is APIException) {
      return RepoResponse(error: response);
    }

    // Check if response has error responseCode (400, 500, etc.)
    if (response is Map<String, dynamic>) {
      final responseCode = response['responseCode'];
      if (responseCode != null && responseCode != 200) {
        // Extract error message from response
        final errorMessage = response['message'] ?? response['error'] ?? 'Failed to reply to complaint';
        return RepoResponse(
          error: APIException(message: errorMessage.toString()),
        );
      }
    }

    // Try to parse as success response
    try {
      return RepoResponse(data: ReplyThreadModel.fromJson(response));
    } catch (e) {
      // If parsing fails, check if it's an error response
      if (response is Map<String, dynamic>) {
        final errorMessage = response['message'] ?? response['error'] ?? 'Failed to reply to complaint';
        return RepoResponse(
          error: APIException(message: errorMessage.toString()),
        );
      }
      return RepoResponse(
        error: APIException(message: 'Failed to parse server response'),
      );
    }
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

  Future<RepoResponse<ComplaintCaseResponseModel>> complaintCase({
    required ComplaintCaseRequestModel data,
    required String? token,
  }) async {
    final response = await network.post(
      token: token,
      path: URLs.complaintCase,
      data: data.toJson(),
    );

    if (response is APIException) {
      return RepoResponse(error: response);
    }

    // Check if response has error responseCode
    if (response is Map<String, dynamic>) {
      final responseCode = response['responseCode'];
      if (responseCode != null && responseCode != 200) {
        final errorMessage = response['message'] ?? response['error'] ?? 'Failed to submit complaint case';
        return RepoResponse(
          error: APIException(message: errorMessage.toString()),
        );
      }
    }

    try {
      return RepoResponse(data: ComplaintCaseResponseModel.fromJson(response));
    } catch (e) {
      debugPrint("Error parsing ComplaintCaseResponseModel: $e");
      if (response is Map<String, dynamic>) {
        final errorMessage = response['message'] ?? response['error'] ?? 'Failed to parse server response';
        return RepoResponse(
          error: APIException(message: errorMessage.toString()),
        );
      }
      return RepoResponse(
        error: APIException(message: 'Failed to parse server response'),
      );
    }
  }
}
