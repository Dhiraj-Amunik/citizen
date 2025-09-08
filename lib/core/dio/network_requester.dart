import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/utils/urls.dart';

class NetworkRequester {
  late Dio _dio;
  NetworkRequester() {
    prepareRequest();
  }

  void prepareRequest() {
    BaseOptions dioOptions = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        baseUrl: URLs.baseURL,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {'Accept': Headers.jsonContentType});
    _dio = Dio(dioOptions);
    _dio.interceptors.clear();
    _dio.interceptors.add(LogInterceptor(
      error: true,
      request: true,
      requestBody: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
      logPrint: _printLog,
    ));
  }

  _printLog(Object object) => log(object.toString());

  Future<dynamic> get(
      {required String path,
      Map<String, dynamic>? query,
      String? token}) async {
    try {
      final options = Options(headers: {});
      if (token != null) {
        options.headers?['Authorization'] = 'Bearer $token';
      }
          
      final response =
          await _dio.get(path, queryParameters: query, options: options);
      return response.data;
    } on DioException catch (dioError) {
      return ExceptionHandler.handleError(dioError);
    }
  }

  Future<dynamic> post({
    required String path,
    Map<String, dynamic>? query,
    dynamic data,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {},
      );

      if (token != null) {
        options.headers?['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.post(
        path,
        queryParameters: query,
        data: data,
        options: options,
        onSendProgress: (count, total) {
          print('$count,$total');
        },
      );

      return response.data;
    } on Exception catch (error) {
      return ExceptionHandler.handleError(error);
    }
  }

  Future<dynamic> put({
    required String path,
    Map<String, dynamic>? query,
    dynamic data,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {},
      );

      if (token != null) {
        options.headers?['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.put(
        path,
        queryParameters: query,
        data: data,
        options: options,
        onSendProgress: (count, total) {
          print('$count,$total');
        },
      );

      return response.data;
    } on Exception catch (error) {
      return ExceptionHandler.handleError(error);
    }
  }

  Future<dynamic> download({
    required String url,
    String? token,
  }) async {
    try {
      final options = Options(
        responseType: ResponseType.bytes,
        headers: {},
      );

      if (token != null) {
        options.headers?['Authorization'] = 'Bearer $token';
      }
      print("started");
      final response = await _dio.get(
        url,
        options: options,
        onReceiveProgress: (count, total) {
          print('$count,$total');
        },
      );
      print("completed");
      return response.data;
    } on Exception catch (error) {
      return ExceptionHandler.handleError(error);
    }
  }
}
