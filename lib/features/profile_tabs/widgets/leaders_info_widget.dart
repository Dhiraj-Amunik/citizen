import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

class LeadersInfoWidget extends StatelessWidget {
  const LeadersInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Container(
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
        blurRadius: 2,
        spreadRadius: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Dimens.gapX2,
        children: [
          Row(
            spacing: Dimens.gapX3,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(Dimens.radius100),
                  child: CommonHelpers.getCacheNetworkImage(
                    "https://upload.wikimedia.org/wikipedia/commons/2/22/Abhay_Singh_Chautala_%28cropped%29.jpg",
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: TranslatedText(
                        text: "Abhay Singh Chautala",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: TranslatedText(
                        text: "Indian National Lok Dal (INLD)",
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                text: "${localization.position} : ",
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppPalettes.blackColor,
                ),
              ),
              Expanded(
                child: TranslatedText(
                  text: "National President",
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppPalettes.blackColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                text: "${localization.experience} : ",
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppPalettes.blackColor,
                ),
              ),
              Expanded(
                child: TranslatedText(
                  text: "Haryana Olympic Association President",
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppPalettes.blackColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                text: localization.key_focus_area,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppPalettes.blackColor,
                ),
              ),
              Row(
                children: [
                  SizeBox.sizeWX5,
                  Expanded(
                    child: Column(
                      children: [
                        FittedBox(
                          child: TranslatedText(
                            text: "• Party leadership & strategic planning",
                          ),
                        ),
                        FittedBox(
                          child: TranslatedText(
                            text: "• National-level governance initiatives",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
