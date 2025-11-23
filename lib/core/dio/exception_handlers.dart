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
          return APIException(
            message:
                ErrorModel.fromJson(error.response?.data).message ??
                HandleError.getHttpErrorMessage(error.response?.statusCode),
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

  static handleError(APIException? error) {
    // Get.rawSnackbar(message: error?.message ?? 'Something went wrong');
    print(error?.message ?? 'Something went wrong');
  }

  static String getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "Bad Request: The request was invalid.";
      case 401:
        CommonSnackbar(
          text:
              "Party Membership successfully approved.\nRe-login to access all membership features.",
        ).showAnimatedDialog(
          type: QuickAlertType.success,
          onTap: () {
            SessionController.instance.clearSession();
          },
        );

        return "Unauthorized: Please login again.";
      case 403:
        return "Forbidden: You don’t have permission to access this resource.";
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
}
