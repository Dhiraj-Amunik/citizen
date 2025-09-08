import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class RatingWidget extends StatelessWidget {
  final int value;
  final Function(double? value)? onChanged;
  const RatingWidget({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RatingStars(
          starCount: 5,
          starSize: 24.spMax,
          maxValue: 5,
       
          starSpacing: 6.w,
          value: value.toDouble(),
          onValueChanged: onChanged,
          maxValueVisibility: false,
          valueLabelVisibility: false,
          animationDuration: Duration(milliseconds: 1000),
          starOffColor: AppPalettes.greyColor,
          starColor: AppPalettes.yellowColor,
        ),
      ],
    );
  }
}
