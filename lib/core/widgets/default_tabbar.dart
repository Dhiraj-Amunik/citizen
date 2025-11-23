import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

class DefaultTabBar extends StatelessWidget {
  final TabController controller;
  final double commonRadius;
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
        padding: EdgeInsetsGeometry.symmetric(horizontal: Dimens.paddingX2),
        labelPadding: EdgeInsetsGeometry.zero,
        unselectedLabelStyle: context.textTheme.bodySmall,
        dividerColor: AppPalettes.liteGreenColor,
        indicatorSize: tabBarSize,
        indicatorColor: AppPalettes.primaryColor,
        indicatorPadding: EdgeInsetsGeometry.zero,
        tabs: tabLabels.asMap().entries.map((entry) {
          return Padding(
            padding: REdgeInsets.symmetric(
              horizontal: Dimens.paddingX2,
            ).copyWith(bottom: Dimens.paddingX2),
            child: TranslatedText(
              text: entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppPalettes.blackColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
