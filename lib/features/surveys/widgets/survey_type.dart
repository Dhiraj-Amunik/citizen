import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/features/surveys/model/survey_model.dart';
import 'package:inldsevak/features/surveys/widgets/choice_widget.dart';
import 'package:inldsevak/features/surveys/widgets/multi_choice_widget.dart';

enum SurveyTypes {
  multipleChoice('multiple-choice'),
  feedback('feedback'),
  description('description');

  const SurveyTypes(this.displayName);
  final String displayName;
}

abstract class SurveyType {
  Widget getWidget();

  factory SurveyType.fromSurveyData(
    Questions data, {
    bool? isEnabled,
    // Function(String?)? feedbackOnTap,
    // TextEditingController? textController,
    List<String>? multiChoiceOptions,
    List<String>? multiChoiceAnswers,
    required List<String> multiChoiceSelected,
    Function(List<String>)? onSelectionChanged,
  }) {
    if (data.type == SurveyTypes.multipleChoice.displayName) {
      return MultiChoice(
        multiChoiceSelected,
        options: multiChoiceOptions ?? [],
        answer: multiChoiceAnswers,
         onSelectionChanged: onSelectionChanged, 
      );
      // } else
      // if (data.type == SurveyTypes.description.displayName) {
      //   return TextInput(
      //     controller: textController ?? TextEditingController(),
      //     isEnabled: isEnabled,
      //   );
      // } else if (data.type == SurveyTypes.feedback.displayName) {
      //   return FeedBack(isEnabled, options: [], onOptionSelected: feedbackOnTap!);
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

// class TextInput implements SurveyType {
//   TextEditingController controller;
//   bool? isEnabled;

//   TextInput({required this.controller, this.isEnabled});
//   @override
//   Widget getWidget() {
//     return _customTextFormField(controller, isEnabled: isEnabled);
//   }
// }

// class Rating implements SurveyType {
//   final int rating;
//   final Function(double? value)? onRatingChanged;
//   Rating({required this.rating, this.onRatingChanged});
//   @override
//   Widget getWidget() {
//     return RatingWidget(value: rating, onChanged: onRatingChanged);
//   }
// }

class MultiChoice implements SurveyType {
  final List<String>? answer;
  final List<String> options;
  final List<String> selected;
final Function(List<String>)? onSelectionChanged;
  MultiChoice(
    this.selected, {
    required this.options,
    this.answer,  this.onSelectionChanged, 
  });

  @override
  Widget getWidget() {
    return MultiChoiceWidget(
      answers: answer,
      options: options,
      selectedOptions: selected, onSelectionChanged: onSelectionChanged, 
    );
  }
}

// class FeedBack implements SurveyType {
//   final bool? isEnabled;
//   final List<String> options;
//   final String? initiallySelected;
//   final ValueChanged<String?> onOptionSelected;

//   FeedBack(
//     this.isEnabled, {
//     required this.options,
//     this.initiallySelected,
//     required this.onOptionSelected,
//   });

//   @override
//   Widget getWidget() {
//     return ChoiceWidget(
//       options: options,
//       onOptionSelected: onOptionSelected,
//       initiallySelected: initiallySelected,
//     );
//   }
// }

class None implements SurveyType {
  @override
  Widget getWidget() {
    return Container();
  }
}

// Widget _customTextFormField(
//   TextEditingController controller, {
//   bool? isEnabled,
// }) {
//   return CommonTextFormField(
//     enabled: isEnabled ?? false,
//     controller: controller,
//     radius: 10,
//     hintText: "Enter your answer",
//   );
// }
