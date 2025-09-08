import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';

class PartyInformationView extends StatelessWidget {
  const PartyInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Scaffold(
      appBar: commonAppBar(title: localization.party_information),
      body: Column(
        children: [
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Dimens.gapX2,
                  children: [
                    SizedBox(
                      height: 100.height(),
                      child: Image.asset("assets/logo/login_image.png"),
                    ),
                    Flexible(
                      child: Text(
                        "Indian National Lok Dal (INLD)",
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                getRow(
                  textTheme,
                  text: localization.party_slogan,
                  desc: "“ Seva hi Hamara Dharma ” (Service is Our Duty)",
                ),
                getRow(
                  textTheme,
                  text: localization.established_year,
                  desc: "1996",
                ),
                getRow(
                  textTheme,
                  text: localization.party_type,
                  desc: "Regional People’s Party",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget getRow(TextTheme style, {required String text, String? desc}) {
  return RichText(
    text: TextSpan(
      style: style.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppPalettes.blackColor,
      ),
      children: [
        TextSpan(text: text),
        TextSpan(text: " : "),
        TextSpan(
          text: desc,
          style: style.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppPalettes.blackColor,
          ),
        ),
      ],
    ),
  );
}
