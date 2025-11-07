import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/surveys/model/request_survey_model.dart';
import 'package:inldsevak/features/surveys/model/survey_model.dart';
import 'package:inldsevak/features/surveys/services/survey_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';

class SurveyViewModel extends BaseViewModel {
  final Map<String, List<String>> _selectedOptionsMap = {};

  List<String> getSelectedOptionsForQuestion(String questionId) {
    return _selectedOptionsMap[questionId] ?? [];
  }

  void setSelectedOptionsForQuestion(
    String questionId,
    List<String> selectedOptions,
  ) {
    _selectedOptionsMap[questionId] = List.from(selectedOptions);
    notifyListeners();
  }

  void clearSelectedOptionsForQuestion(String questionId) {
    _selectedOptionsMap.remove(questionId);
    notifyListeners();
  }

  List<Questions> surveysList = [];

  @override
  Future<void> onInit() {
    getSurveysList();
    return super.onInit();
  }

  Future<void> getSurveysList() async {
    try {
      isLoading = true;
      surveysList.clear();

      final response = await SurveyRepository().getSurveys(token);

      if (response.data?.responseCode == 200) {
        List<Survey>? data = response.data?.data?.survey;
        if (data?.isNotEmpty == true) {
          data?.forEach((survey) {
            surveysList.addAll(List.from(survey.questions as List));
          });
        } else {
          CommonSnackbar(text: "No Surveys Found").showToast();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> submitSurvey({
    required String surveyID,
    required String questionID,
    required String type,
    List<String>? option,
  }) async {
    try {
      final selectedOptions = _selectedOptionsMap[questionID] ?? option ?? [];
      if (selectedOptions.isEmpty) {
        return CommonSnackbar(
          text: "Select one option to apply changes",
        ).showToast();
      }
      isLoading = true;
      final model = RequestSurveyAnswer(
        surveyId: surveyID,
        answer: Answer(
          question: questionID,
          type: type,
          selectedOptions: selectedOptions.first,
        ),
      );

      final response = await SurveyRepository().postSurvey(token, data: model);

      if (response.data?.responseCode == 200) {
        getSurveysList();

        await CommonSnackbar(
          text: response.data?.message ?? "Survey submitted successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      CommonSnackbar(text: "Something went wrong").showToast();
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }
}
