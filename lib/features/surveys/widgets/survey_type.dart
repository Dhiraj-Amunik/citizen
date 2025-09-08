import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/features/surveys/model/survey_model.dart';
import 'package:inldsevak/features/surveys/widgets/choice_widget.dart';
import 'package:inldsevak/features/surveys/widgets/multi_choice_widget.dart';
import 'package:inldsevak/features/surveys/widgets/rating_widget.dart';

abstract class SurveyType {
  Widget getWidget();

  factory SurveyType.fromSurveyData(
    SurveyData data, {
    bool? isEnabled,
    ValueChanged<Map<String, bool>>? onSelectionChanged,
    TextEditingController? textController,
    int? rating,
    Function(double? value)? onRatingChanged,
    bool? isYesSelected,
    bool? isNoSelected,
    Function()? onYesSelected,
    Function()? onNoSelected,
    List<String>? answer,
  }) {
    if (data.isMultipleChoiceSurvey) {
      return MultiChoice(
        isEnabled,
        options: data.options ?? {},
        onSelectionChanged: onSelectionChanged,
        answer: answer,
      );
    } else if (data.isRatingSurvey) {
      return Rating(rating: rating ?? 0, onRatingChanged: onRatingChanged);
    } else if (data.isTextInputSurvey) {
      return TextInput(
        controller: textController ?? TextEditingController(),
        isEnabled: isEnabled,
      );
    } else if (data.isYesOrNoSurvey) {
      return None();
    } else {
      return None();
    }
  }
}

class Choice implements SurveyType {
  final List<String> options;
  final String? initiallySelected;
  final void Function(String?) onOptionSelected;
  Choice(this.options, this.initiallySelected, this.onOptionSelected);
  @override
  Widget getWidget() {
    return ChoiceWidget(
      options: options,
      initiallySelected: initiallySelected,
      onOptionSelected: onOptionSelected,
    );
  }
}

class TextInput implements SurveyType {
  TextEditingController controller;
  bool? isEnabled;

  TextInput({required this.controller, this.isEnabled});
  @override
  Widget getWidget() {
    return _customTextFormField(controller, isEnabled: isEnabled);
  }
}

class Rating implements SurveyType {
  final int rating;
  final Function(double? value)? onRatingChanged;
  Rating({required this.rating, this.onRatingChanged});
  @override
  Widget getWidget() {
    return RatingWidget(value: rating, onChanged: onRatingChanged);
  }
}

class MultiChoice implements SurveyType {
  final List<String>? answer;
  final Map<String, String> options;
  final ValueChanged<Map<String, bool>>? onSelectionChanged;
  final bool? isEnabled;

  MultiChoice(
    this.isEnabled, {
    required this.options,
    this.onSelectionChanged,
    this.answer,
  });

  @override
  Widget getWidget() {
    return MultiChoiceWidget(
      answers: answer,
      options: options,
      isEnabled: isEnabled,
      onSelectionChanged: onSelectionChanged,
    );
  }
}

class None implements SurveyType {
  @override
  Widget getWidget() {
    return Container();
  }
}

Widget _customTextFormField(
  TextEditingController controller, {
  bool? isEnabled,
}) {
  return CommonTextFormField(
    enabled: isEnabled ?? false,
    controller: controller,
    radius: 10,
    hintText: "Enter your answer",
  );
}
