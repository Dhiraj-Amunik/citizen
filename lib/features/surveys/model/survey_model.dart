import 'package:intl/intl.dart';
import 'dart:convert';

class SurveyModel {
  final String message;
  final int responseCode;
  final String status;
  final List<SurveyData> data;

  SurveyModel({
    required this.message,
    required this.responseCode,
    required this.status,
    required this.data,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) => SurveyModel(
    message: json['message'],
    responseCode: json['responseCode'],
    status: json['status'],
    data: (json['data'] as List).map((e) => SurveyData.fromJson(e)).toList(),
  );
}

class SurveyData {
  final DateTime endDate;
  final String id;
  final bool isMultipleChoiceSurvey;
  final bool isRatingSurvey;
  final bool isSubmitted;
  final bool isTextInputSurvey;
  final bool isYesOrNoSurvey;
  final Map<String, String>? options;
  final DateTime startDate;
  final String surveyQuery;
  final SubmittedData? submittedData;

  SurveyData({
    required this.endDate,
    required this.id,
    required this.isMultipleChoiceSurvey,
    required this.isRatingSurvey,
    required this.isSubmitted,
    required this.isTextInputSurvey,
    required this.isYesOrNoSurvey,
    this.options,
    required this.startDate,
    required this.surveyQuery,
    this.submittedData,
  });

  factory SurveyData.fromJson(Map<String, dynamic> json) {
    return SurveyData(
      endDate: _parseDate(json['end_date']),
      id: json['id'],
      isMultipleChoiceSurvey: json['is_multiple_choice_survey'] == 1,
      isRatingSurvey: json['is_rating_survey'] == 1,
      isSubmitted: json['is_submitted'],
      isTextInputSurvey: json['is_text_input_survey'] == 1,
      isYesOrNoSurvey: json['is_yes_or_no_survey'] == 1,
      options:
          json['options'] == null
              ? null
              : Map<String, String>.from(
                json['options'].map((k, v) => MapEntry(k.toString(), v)),
              ),
      startDate: _parseDate(json['start_date']),
      surveyQuery: json['survey_query'],
      submittedData:
          json['submitted_data'] != null
              ? SubmittedData.fromJson(json['submitted_data'])
              : null,
    );
  }

  static DateTime _parseDate(String dateString) {
    final format = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
    return format.parse(dateString.replaceFirst(' GMT', ''));
  }
}

class SubmittedData {
  final List<String>? choiceAnswer;
  final bool isMultipleChoiceSurvey;
  final bool isRatingSurvey;
  final bool isTextInputSurvey;
  final bool isYesOrNoSurvey;
  final int? rating;
  final dynamic selectedOption;
  final DateTime submittedAt;
  final String? textReview;
  final bool? yesOrNo;

  SubmittedData({
    this.choiceAnswer,
    required this.isMultipleChoiceSurvey,
    required this.isRatingSurvey,
    required this.isTextInputSurvey,
    required this.isYesOrNoSurvey,
    this.rating,
    this.selectedOption,
    required this.submittedAt,
    this.textReview,
    this.yesOrNo,
  });

  factory SubmittedData.fromJson(Map<String, dynamic> json) {
    return SubmittedData(
      choiceAnswer: _parseChoiceAnswer(json['choice_answer']),
      isMultipleChoiceSurvey: json['is_multiple_choice_survey'] == 1,
      isRatingSurvey: json['is_rating_survey'] == 1,
      isTextInputSurvey: json['is_text_input_survey'] == 1,
      isYesOrNoSurvey: json['is_yes_or_no_survey'] == 1,
      rating: json['rating'],
      selectedOption: json['selected_option'],
      submittedAt: SurveyData._parseDate(json['submitted_at']),
      textReview: json['text_review'],
      yesOrNo:
          json['yes_or_no'] == 1
              ? true
              : (json['yes_or_no'] == 0 ? false : null),
    );
  }

  static List<String>? _parseChoiceAnswer(dynamic value) {
    if (value == null || value == "null") return null;
    final decoded = jsonDecode(value) as List;
    return decoded.map((e) => e.toString()).toList();
  }
}
