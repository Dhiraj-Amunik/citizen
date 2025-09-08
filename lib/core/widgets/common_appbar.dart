import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/clipper/app_bar_clipper.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

PreferredSize commonAppBar({
  double appBarHeight = 100,
  PreferredSize? bottom,
  bool showClipper = true,
  Color? statusBarColor = AppPalettes.gradientFirstColor,
  Color? bgColor,
  bool foregroundColor = true,
  Widget? child,
  String? title,
  List<Widget>? action,
  bool center = true,
  Brightness? statusBarMode = Brightness.light,
  TextStyle? style,
  double? elevation,
}) => PreferredSize(
  preferredSize: Size.fromHeight(appBarHeight),
  child: ClipPath(
    clipper: showClipper ? AppBarClipper() : null,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: [0.0, 0.5],
          colors: [
            AppPalettes.gradientFirstColor,
            AppPalettes.gradientSecondColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        iconTheme: IconThemeData(color: AppPalettes.whiteColor),
        leadingWidth: 60.height(),
        toolbarHeight: appBarHeight,
        surfaceTintColor: AppPalettes.transparentColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: statusBarMode,
        ),
        elevation: elevation,
        foregroundColor: AppPalettes.transparentColor,
        titleSpacing: 0,
        backgroundColor: AppPalettes.transparentColor,
        centerTitle: center,
        bottom: bottom,
        title:
            (child ??
                    Text(
                      title ?? "",
                      style:
                          style ??
                          AppStyles.titleMedium.copyWith(
                            color: AppPalettes.whiteColor,
                          ),
                    ))
                .horizontalPadding(Dimens.horizontalspacing),
        actions: action,
        actionsPadding: EdgeInsets.only(right: Dimens.horizontalspacing),
      ),
    ),
  ),
);
