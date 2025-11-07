import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/surveys/model/request_survey_model.dart';
import 'package:inldsevak/features/surveys/model/success_model.dart';
import 'package:inldsevak/features/surveys/model/survey_model.dart';

class SurveyRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<SurveyModel>> getSurveys(String? token) async {
    final response = await _network.post(path: URLs.surveys, token: token);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: SurveyModel.fromJson(response));
  }

  Future<RepoResponse<SuccessModel>> postSurvey(
    String? token, {
    required RequestSurveyAnswer data,
  }) async {
    final response = await _network.post(
      path: URLs.submitSurveys,
      token: token,
      data: data.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: SuccessModel.fromJson(response));
  }
}
