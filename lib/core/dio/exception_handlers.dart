import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:inldsevak/core/dio/error_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';

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
          CommonSnackbar(text: 'Please try again later').showSnackbar();
          log("connectionTimeout");

          return APIException(message: 'connectionTimeout');
        case DioExceptionType.receiveTimeout:
          CommonSnackbar(
            text: 'Server is not responding, please try again later.',
          ).showSnackbar();
          log("connectionTimeout");
          return APIException(message: 'connectionTimeout');

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
          CommonSnackbar(text: 'Something went wrong').showSnackbar();
          return APIException(message: 'something went wrong');
      }
    } else {
      CommonSnackbar(text: 'Something went wrong2').showSnackbar();

      return APIException(message: 'Something went wrong');
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
