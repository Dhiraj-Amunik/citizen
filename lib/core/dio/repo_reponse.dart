import 'package:inldsevak/core/dio/api_status_enum.dart';
import 'package:inldsevak/core/dio/exception_handlers.dart';

class RepoResponse<T> {
  final APIException? error;
  final T? data;
  final ApiStatus? status;

  RepoResponse({this.error, this.data, this.status});

  // Named constructor for success state
  RepoResponse.success(this.data) : status = ApiStatus.completed, error = null;

  // Named constructor for error state
  RepoResponse.error(this.error) : status = ApiStatus.error, data = null;
}
