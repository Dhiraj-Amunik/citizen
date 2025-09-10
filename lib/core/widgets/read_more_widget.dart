import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:readmore/readmore.dart';

class ReadMoreWidget extends StatelessWidget {
  final String text;
  const ReadMoreWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return ReadMoreText(
      text,
      trimLines: 2,
      trimMode: TrimMode.Line,
      textAlign: TextAlign.left,
      trimCollapsedText: ' Read more',
      trimExpandedText: ' Show less',
      moreStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      lessStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      style: AppStyles.bodyMedium.copyWith(
        color: AppPalettes.lightTextColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
