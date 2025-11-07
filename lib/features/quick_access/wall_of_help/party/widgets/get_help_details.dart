
import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';

Widget getHelpDetails({required String text, String? desc}) {
  return RichText(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    text: TextSpan(
      style: AppStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w500,
        color: AppPalettes.blackColor,
      ),
      children: [
        TextSpan(text: text),
        TextSpan(text: " : "),
        TextSpan(
          text: desc,
          style: AppStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w400,
            color: AppPalettes.lightTextColor,
          ),
        ),
      ],
    ),
  );
}