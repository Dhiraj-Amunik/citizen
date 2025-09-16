import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
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
}) => PreferredSize(
  preferredSize: Size.fromHeight(appBarHeight.r),
  child: AppBar(
    leadingWidth: 60.height(),
    toolbarHeight: appBarHeight.r,
    surfaceTintColor: AppPalettes.transparentColor,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: statusBarMode,
    ),
    elevation: elevation,
    shadowColor: AppPalettes.shadowColor,
    foregroundColor: AppPalettes.whiteColor,
    backgroundColor: AppPalettes.whiteColor,
    centerTitle: center,
    bottom: bottom,
    title:
        (child ??
                Text(
                  title ?? "",
                  style:
                      style ??
                      AppStyles.headlineMedium.copyWith(
                        color: AppPalettes.blackColor,
                      ),
                ))
            .horizontalPadding(Dimens.horizontalspacing),
    actions: action,
    actionsPadding: EdgeInsets.only(right: Dimens.horizontalspacing),
  ),
);
