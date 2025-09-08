import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppStyles {
  AppStyles._privateConstructor();

  // display Light ---------------------------->
  static final displaySmall = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 26.sp,
  );
  static final displayMediumn = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.sp,
  );
  static final displayLarge = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 30.sp,
  );
  //<-----------------------------------------

  // headings Light -------------------------->
  static final headlineSmall = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
  );
  static final headlineMedium = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
  );
  static final headlineLarge = TextStyle(
    fontSize: 26.sp,
    fontWeight: FontWeight.w500,
  );
  //<-----------------------------------------

  // Title Light ---------------------------->
  static final titleSmall = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.spMax,
    color: AppPalettes.blackColor,
  );
  static final titleMedium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18.spMax,
    color: AppPalettes.blackColor,
  );
  static final titleLarge = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20.spMax,
    color: AppPalettes.blackColor,
  );
  //<-----------------------------------------

  // Body Light ---------------------------->
  static final bodySmall = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.spMax,
  );
  static final bodyMedium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.spMax,
  );
  static final bodyLarge = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18.spMin,
  );
  //<-----------------------------------------

  // label Light ---------------------------->
  static final labelSmall = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 10.spMin,
  );
  static final labelMedium = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.spMax,
  );
  static final labelLarge = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.spMax,
  );
  //<-----------------------------------------

  static const errorStyle = TextStyle(
    color: AppPalettes.redColor,
    fontWeight: FontWeight.w500,
    fontSize: 10,
  );
}
