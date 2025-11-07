class RequestSurveyAnswer {
  final String surveyId;
  final Answer answer;

  RequestSurveyAnswer({
    required this.surveyId,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'surveyId': surveyId,
      'answer': answer.toJson(),
    };
  }
}

class Answer {
  final String question;
  final String type;
  final String selectedOptions;

  Answer({
    required this.question,
    required this.type,
    required this.selectedOptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'type': type,
      'selectedOptions': selectedOptions,
    };
  }
}