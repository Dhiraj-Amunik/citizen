import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/surveys/view_model/survey_view_model.dart';
import 'package:inldsevak/features/surveys/widgets/survey_type.dart';
import 'package:provider/provider.dart';

class SurveyView extends StatelessWidget {
  const SurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<SurveyViewModel>();
    return Scaffold(
      appBar: commonAppBar(title: localization.survey),
      body: RefreshIndicator(
        onRefresh: () async {
          provider.getSurveysList();
        },
        child: Consumer<SurveyViewModel>(
          builder: (context, survey, _) {
            if (survey.isLoading) {
              return Center(child: CustomAnimatedLoading());
            }
            if (survey.surveysList.isEmpty) {
              return Center(
                child: Text("No Surveys found", style: textTheme.bodyMedium),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.paddingX,
              ).copyWith(bottom: Dimens.verticalspacing),
              itemBuilder: (context, index) {
                final data = survey.surveysList[index];
                final multiChoiceSelected = survey
                    .getSelectedOptionsForQuestion(data.sId ?? "");
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.paddingX4,
                    vertical: Dimens.paddingX3,
                  ),
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX4,
                    border: BoxBorder.all(color: AppPalettes.primaryColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}. ${data.text}",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizeBox.sizeHX3,
                      SurveyType.fromSurveyData(
                        data,
                        multiChoiceAnswers: data.userAnswer == null
                            ? []
                            : [data.userAnswer?.selectedOptions ?? ""],
                        multiChoiceOptions: data.options,
                        multiChoiceSelected: multiChoiceSelected,
                        onSelectionChanged: (newSelection) {
                          survey.setSelectedOptionsForQuestion(
                            data.sId ?? "",
                            newSelection,
                          );
                        },
                      ).getWidget(),
        
                      if (data.userAnswer == null)
                        Padding(
                          padding: EdgeInsets.only(top: Dimens.paddingX3B),
                          child: Row(
                            spacing: Dimens.gapX2,
                            children: [
                              Expanded(
                                child: CommonButton(
                                  onTap: () {
                                    survey.clearSelectedOptionsForQuestion(
                                      data.sId ?? "",
                                    );
                                  },
                                  height: 40,
                                  radius: Dimens.radiusX2,
                                  color: AppPalettes.whiteColor,
                                  borderColor: AppPalettes.primaryColor,
                                  textColor: AppPalettes.primaryColor,
                                  text: localization.clear,
                                  padding: EdgeInsets.symmetric(
                                    vertical: Dimens.paddingX2,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CommonButton(
                                  height: 40,
                                  radius: Dimens.radiusX2,
                                  padding: EdgeInsets.symmetric(
                                    vertical: Dimens.paddingX2,
                                  ),
                                  text: localization.apply,
                                  onTap: () {
                                    survey.submitSurvey(
                                      surveyID: data.surveyID ?? "",
                                      questionID: data.sId ?? "",
                                      type: data.type ?? "",
                                      option: multiChoiceSelected,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, _) => SizeBox.sizeHX3,
              itemCount: survey.surveysList.length,
            );
          },
        ),
      ),
    );
  }
}




      /*SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
        ),
        child: Column(
          spacing: Dimens.widgetSpacing,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.paddingX3,
                vertical: Dimens.paddingX3,
              ),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX2,
                blurRadius: 2,
                spreadRadius: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                spacing: Dimens.gapX2,
                children: [
                  Text(
                    "Q1. How satisfied are you with MLA’s office response time?",
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ChoiceWidget(
                    options: [
                      "Very Satisfied",
                      "Satisfied",
                      "Neutral",
                      "Dissatisfied",
                    ],
                    onOptionSelected: (selected) {},
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.paddingX3,
                vertical: Dimens.paddingX3,
              ),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX2,
                blurRadius: 2,
                spreadRadius: 2,
              ),
              child: Column(
                spacing: Dimens.gapX2,
                children: [
                  Text(
                    "Q2. Which areas need more attention? (Select all that apply)",
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  MultiChoiceWidget(
                    isEnabled: true,
                    selectedOptions: [],
                    options: [
                      "Roads",
                      "Health",
                      "Education",
                      "Water Supply",
                      "Other",
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),*/