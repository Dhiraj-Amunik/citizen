import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Scaffold(
      appBar: commonAppBar(title: localization.about),
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.appBarSpacing,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX4,
          vertical: Dimens.paddingX4,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX2,
          spreadRadius: 2,
          blurRadius: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              text: "Mission Statement:",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.height()),
            TranslatedText(
              text: "To empower citizens by ensuring transparency in governance, supporting local development, and promoting equality in society.",
              style: textTheme.bodySmall?.copyWith(
                color: AppPalettes.lightTextColor,
              ),
            ),

            SizedBox(height: 16.height()),
            TranslatedText(
              text: "Vision / Objectives:",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.height()),
            TranslatedText(
              text: '''• Build a corruption-free system.
• Encourage youth participation in politics.
• Provide better healthcare and education facilities.
• Strengthen local employment opportunities.
• Promote sustainable development and environmental care.''',
              style: textTheme.bodySmall?.copyWith(
                color: AppPalettes.lightTextColor,
              ),
            ),
            SizedBox(height: 16.height()),
            TranslatedText(
              text: "Short History",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.height()),
            TranslatedText(
              text: "The Indian National Lok Dal (INLD) is a political party based primarily in the Indian state of Haryana. It was initially founded as the Haryana Lok Dal (Rashtriya) by Devi Lal in 1996, who served as the Deputy Prime Minister of India.",
              style: textTheme.bodySmall?.copyWith(
                color: AppPalettes.lightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
