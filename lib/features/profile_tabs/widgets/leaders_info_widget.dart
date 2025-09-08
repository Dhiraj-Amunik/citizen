import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

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
                      child: Text(
                        "Abhay Singh Chautala",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        "Indian National Lok Dal (INLD)",
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          CommonHelpers.getRow(
            textTheme,
            text: localization.position,
            desc: "National President",
          ),
          CommonHelpers.getRow(
            textTheme,
            text: localization.experience,
            desc: "Haryana Olympic Association President",
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHelpers.getRow(
                textTheme,
                text: localization.key_focus_area,
              ),
              Row(
                children: [
                  SizeBox.sizeWX5,
                  Expanded(
                    child: Column(
                      children: [
                        FittedBox(
                          child: Text(
                            "• Party leadership & strategic planning",
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "• National-level governance initiatives",
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
