import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class CustomAnimatedLoading extends StatelessWidget {
  const CustomAnimatedLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimens.scaleX4,
      width: Dimens.scaleX4,
      child: CircularProgressIndicator(
        backgroundColor: AppPalettes.primaryColor.withOpacityExt(0.2),
        color: AppPalettes.primaryColor,
        strokeWidth: Dimens.paddingX1B,
        strokeCap: StrokeCap.round,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
