import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';
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
  Widget? leading,
}) {
  final navigatorContext = RouteManager.navigatorKey.currentContext;
  final bool canPop =
      navigatorContext != null ? Navigator.canPop(navigatorContext) : false;

  final Widget? effectiveLeading = canPop
      ? leading ??
          Padding(
            padding: EdgeInsets.only(
              left: Dimens.horizontalspacing,
            ),
            child: Center(
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalettes.liteGreenColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalettes.liteGreenColor.withOpacityExt(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(
                      RouteManager.navigatorKey.currentContext!,
                    ).pop(),
                    child: Center(
                      child: Icon(
                        Icons.chevron_left,
                        color: AppPalettes.blackColor,
                        size: 24.r,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
      : null;

  return PreferredSize(
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
      leading: effectiveLeading,
      leadingWidth: canPop ? 60.r : 0,
      iconTheme: iconColor != null ? IconThemeData(color: iconColor) : null,
      title: child?.horizontalPadding(Dimens.horizontalspacing) ??
          Text(
            title ?? "",
            style: style ??
                AppStyles.headlineMedium.copyWith(
                  color: AppPalettes.blackColor,
                ),
          ),
      actions: action,
      actionsPadding: EdgeInsets.only(right: Dimens.horizontalspacing),
    ),
  );
}
