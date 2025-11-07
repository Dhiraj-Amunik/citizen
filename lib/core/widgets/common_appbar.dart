import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

PreferredSize commonAppBar({
  double appBarHeight = 60,
  PreferredSize? bottom,
  bool showClipper = true,
  Color? statusBarColor = AppPalettes.whiteColor,
  Color? bgColor,
  bool foregroundColor = true,
  Widget? child,
  String? title,
  List<Widget>? action,
  bool center = true,
  Brightness? statusBarMode = Brightness.dark,
  TextStyle? style,
  double? elevation,
  double? scrollElevation,
  Color? iconColor,
}) => PreferredSize(
  preferredSize: Size.fromHeight(appBarHeight.r),
  child: AppBar(
    toolbarHeight: appBarHeight.r,
    surfaceTintColor: AppPalettes.transparentColor,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: statusBarMode,
    ),
    elevation: elevation,
    scrolledUnderElevation: scrollElevation,
    shadowColor: AppPalettes.shadowColor,
    foregroundColor: AppPalettes.whiteColor,
    backgroundColor: bgColor ?? AppPalettes.whiteColor,
    centerTitle: center,
    bottom: bottom,
    titleSpacing: 0,
    iconTheme: iconColor != null ? IconThemeData(color: iconColor) : null,
    title:
        (child?.horizontalPadding(Dimens.horizontalspacing) ??
        Text(
          title ?? "",
          style:
              style ??
              AppStyles.headlineMedium.copyWith(color: AppPalettes.blackColor),
        )),
    actions: action,
    actionsPadding: EdgeInsets.only(right: Dimens.horizontalspacing),
  ),
);
