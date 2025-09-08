import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/widgets/interest_choice_widget.dart';
import 'package:inldsevak/features/surveys/widgets/choice_widget.dart';
import 'package:inldsevak/features/surveys/widgets/multi_choice_widget.dart';
import 'package:inldsevak/features/surveys/widgets/rating_widget.dart';

class SurveyView extends StatelessWidget {
  const SurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Scaffold(
      appBar: commonAppBar(title: localization.survey),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.appBarSpacing,
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
                  InterestChoiceWidget(
                    selected: [],
                    options: [
                      "Roads",
                      "Health",
                      "Education",
                      "Water Supply",
                      "Other",
                    ],
                    onSelectionChanged: (selected) {},
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
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Dimens.gapX2,
                children: [
                  Text(
                    "Q3. Rate the cleanliness in your ward.",
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  RatingWidget(value: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
