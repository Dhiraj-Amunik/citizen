import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:inldsevak/core/dio/error_model.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:quickalert/models/quickalert_type.dart';

class APIException implements Exception {
  String message;
  APIException({required this.message});
}

class ExceptionHandler {
  ExceptionHandler._privateConstructor();

  static APIException handleError(Exception error) {
    if (error is DioException) {
      log("--------> ${error.type}");
      switch (error.type) {
        case DioExceptionType.badResponse:
          final errorMessage = ErrorModel.fromJson(error.response?.data).message;
          return APIException(
            message:
                errorMessage ??
                HandleError.getHttpErrorMessage(
                  error.response?.statusCode,
                  error.response?.data,
                  error.requestOptions,
                ),
          );
        case DioExceptionType.connectionError:
          CommonSnackbar(text: 'Please check your network').showSnackbar();
          return APIException(message: 'Please check your network');
        case DioExceptionType.connectionTimeout:
          CommonSnackbar(
            text: 'Connection timeout. Please check your internet connection and try again.',
          ).showSnackbar();
          log("connectionTimeout: ${error.message}");

          return APIException(message: 'Connection timeout. Please try again.');
        case DioExceptionType.receiveTimeout:
          CommonSnackbar(
            text: 'Server is taking too long to respond. Please try again in a moment.',
          ).showSnackbar();
          log("receiveTimeout: ${error.message}");
          return APIException(message: 'Server timeout. Please try again.');
        case DioExceptionType.sendTimeout:
          CommonSnackbar(
            text: 'Request is taking too long to send. Please check your connection and try again.',
          ).showSnackbar();
          log("sendTimeout: ${error.message}");
          return APIException(message: 'Send timeout. Please try again.');

        case DioExceptionType.cancel:
          CommonSnackbar(text: "Request Cancelled: The request was aborted.");
          log('Error: Request Cancelled');
          return APIException(
            message: 'Request was cancelled, please try again.',
          );
        case DioExceptionType.unknown:
          CommonSnackbar(
            text: "Unexpected Error: Something went wrong.",
          ).showSnackbar();
          log('Error: Unknown Network Issue - ${error.message}');
          return APIException(
            message: 'Unexpected error occurred, please check your connection.',
          );

        default:
          CommonSnackbar(
            text: 'Network error occurred. Please try again.',
          ).showSnackbar();
          return APIException(message: 'Network error. Please try again.');
      }
    } else {
      CommonSnackbar(
        text: 'An unexpected error occurred. Please try again.',
      ).showSnackbar();

      return APIException(message: 'Unexpected error. Please try again.');
    }
  }
}

class HandleError {
  HandleError._privateConstructor();
  
  // Flag to prevent showing party member approval dialog multiple times
  static bool _hasShownPartyMemberApprovalDialog = false;

  static handleError(APIException? error) {
    // Get.rawSnackbar(message: error?.message ?? 'Something went wrong');
    print(error?.message ?? 'Something went wrong');
  }
  
  // Reset the flag when session is cleared
  static void resetPartyMemberApprovalFlag() {
    _hasShownPartyMemberApprovalDialog = false;
  }

  static String getHttpErrorMessage(int? statusCode, [dynamic responseData, RequestOptions? requestOptions]) {
    switch (statusCode) {
      case 400:
        return "Bad Request: The request was invalid.";
      case 401:
        // Only show success message if it's actually a party member approval
        // and we haven't shown it already in this session
        if (!_hasShownPartyMemberApprovalDialog && 
            _isPartyMemberApproval(responseData, requestOptions)) {
          _hasShownPartyMemberApprovalDialog = true;
          CommonSnackbar(
            text: "Party member request approved. Please relogin.",
          ).showAnimatedDialog(
            type: QuickAlertType.success,
            onTap: () {
              _hasShownPartyMemberApprovalDialog = false;
              SessionController.instance.clearSession();
            },
          );
        } else if (!_hasShownPartyMemberApprovalDialog) {
          // Regular 401 error - just show unauthorized message
          CommonSnackbar(
            text: "Unauthorized: Please login again.",
          ).showSnackbar();
        }
        return "Unauthorized: Please login again.";
      case 403:
        return "Forbidden: You don't have permission to access this resource.";
      case 404:
        return "Not Found: The requested resource was not found.";
      case 500:
        return "Server Error: The server encountered an error.";
      case 502:
        return "Bad Gateway: The server received an invalid response.";
      case 503:
        return "Service Unavailable: The server is temporarily unavailable.";
      default:
        return "Unexpected error occurred.";
    }
  }

  /// Check if the error response indicates party member approval
  /// The backend returns 401 when party member is approved because the token needs to be refreshed
  static bool _isPartyMemberApproval(dynamic responseData, RequestOptions? requestOptions) {
    try {
      // First, check if response data has a message indicating approval
      if (responseData != null && responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString().toLowerCase() ?? '';
        final hasPartyKeyword = message.contains('party') || message.contains('membership');
        final hasApprovedKeyword = message.contains('approved') || message.contains('approval');
        
        if (hasPartyKeyword && hasApprovedKeyword) {
          return true;
        }
      }
      
      // If message is null or doesn't indicate approval, check JWT token
      // When party member is approved, the token has partyMemberId: null
      // and needs to be refreshed, causing 401 errors
      if (requestOptions != null) {
        final authHeader = requestOptions.headers['Authorization'] as String?;
        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7);
          final tokenPayload = _decodeJwtPayload(token);
          
          if (tokenPayload != null) {
            final partyMemberId = tokenPayload['partyMemberId'];
            
            // Check if token has null partyMemberId
            // When party member is approved, the old token becomes invalid
            // because it doesn't have the new partyMemberId, causing 401 errors
            // This is a strong indicator of party member approval
            if (partyMemberId == null) {
              log("Detected potential party member approval: token has null partyMemberId");
              return true;
            }
          }
        }
      }
      
      return false;
    } catch (e) {
      log("Error checking party member approval: $e");
      return false;
    }
  }
  
  /// Decode JWT token payload
  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = base64.normalize(payload);
      final decoded = utf8.decode(base64Decode(normalizedPayload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      log("Error decoding JWT token: $e");
      return null;
    }
  }
}
