import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

Widget getHelpDetails({required String text, String? desc}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TranslatedText(
        text: "$text : ",
        style: AppStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: AppPalettes.blackColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Expanded(
        child: TranslatedText(
          text: desc ?? "",
          style: AppStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w400,
            color: AppPalettes.lightTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}