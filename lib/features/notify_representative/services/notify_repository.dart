import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/notify_representative/model/request/nr_pagination_model.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';
import 'package:inldsevak/features/surveys/model/success_model.dart';

class NotifyRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<NotifyListModel>> getNotifyRepresentative({
    String? token,
    NotifyReprPaginationModel? model,
  }) async {
    final response = await _network.post(
      path: URLs.getListNotifyRepresentative,
      token: token,
      data: model?.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: NotifyListModel.fromJson(response));
  }

  Future<RepoResponse<SuccessModel>> createNotify({
    String? token,
    required RequestNotifytModel model,
  }) async {
    final response = await _network.post(
      path: URLs.postNotifyRepresentative,
      token: token,
      data: model.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: SuccessModel.fromJson(response));
  }

  Future<RepoResponse<SuccessModel>> deleteNotify({
    String? token,
    required String id,
  }) async {
    final response = await _network.post(
      path: URLs.deleteNotifyRepresentative,
      token: token,
      data: {"NotifyRepresentativeId": id},
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: SuccessModel.fromJson(response));
  }

  Future<RepoResponse<NotifyFiltersModel>> getNotifyFilters({
    String? token,
  }) async {
    final response = await _network.get(
      token: token,
      path: URLs.getNotifyFilters,
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: NotifyFiltersModel.fromJson(response));
  }
}
