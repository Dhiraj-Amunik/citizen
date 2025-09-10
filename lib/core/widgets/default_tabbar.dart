import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class DefaultTabBar extends StatelessWidget {
  final TabController controller;
  final double commonRadius;
  final double? height;
  final double? fontSize;
  final List<String> tabLabels;
  final TabBarIndicatorSize? tabBarSize;
  final Color? unSelectedTabColor;
  final TabAlignment? alignment;
  final bool isScrollable;

  const DefaultTabBar({
    required this.controller,
    required this.tabLabels,
    this.isScrollable = false,
    this.height,
    this.fontSize,
    this.commonRadius = 28,
    super.key,
    this.tabBarSize = TabBarIndicatorSize.label,
    this.alignment,
    this.unSelectedTabColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalettes.transparentColor,
      shadowColor: AppPalettes.liteGreyColor,
      child: TabBar(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll(AppPalettes.transparentColor),
        controller: controller,
        labelStyle: context.textTheme.bodySmall,
        isScrollable: isScrollable,
        tabAlignment: isScrollable ? TabAlignment.start : null,
        padding: EdgeInsetsGeometry.zero,
        labelPadding: EdgeInsetsGeometry.zero,
        unselectedLabelStyle: context.textTheme.bodySmall,
        dividerColor: AppPalettes.transparentColor,
        indicatorSize: tabBarSize,
        indicatorColor: AppPalettes.primaryColor,
        indicatorPadding: EdgeInsetsGeometry.zero,
        tabs: tabLabels.asMap().entries.map((entry) {
          return Padding(
            padding: REdgeInsets.symmetric(
              horizontal: Dimens.paddingX2,
            ).copyWith(bottom: Dimens.paddingX2),
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppPalettes.blackColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
