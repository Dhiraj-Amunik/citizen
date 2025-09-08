import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class CommonExpandedWidget extends StatelessWidget {
  final Widget? svg;
  final String title;
  final String? subtTitle;
  final TextStyle? textStyle;
  final TextStyle? subTitleTextStyle;
  final List<Widget> children;
  final bool initialExpand;
  final double radius;
  final EdgeInsets? padding;
  final double? childrenPadding;
  final double? childrenBottomPadding;
  final Alignment? alignment;
  final double? titleFontSize;
  final double? elevation;
  final Color? iconColor;
  final Color? splashColor;

  const CommonExpandedWidget({
    super.key,
    required this.title,
    this.subtTitle,
    required this.children,
    this.initialExpand = false,
    this.padding,
    required this.radius,
    this.svg,
    this.textStyle,
    this.subTitleTextStyle,
    this.alignment,
    this.titleFontSize,
    this.childrenPadding,
    this.childrenBottomPadding,
    this.elevation = 2,
    this.iconColor,
    this.splashColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundedWithShadow(
        radius,
        spreadRadius: elevation,
        blurRadius: elevation,
      ),
      child: Theme(
        data: ThemeData(splashColor: splashColor),
        child: ExpansionTile(
          expandedAlignment: alignment,
          maintainState: true,
          leading: svg,
          initiallyExpanded: initialExpand,
          tilePadding: padding,
          minTileHeight: 0,
          childrenPadding: EdgeInsets.symmetric(
            horizontal: childrenPadding ?? 0,
          ).copyWith(bottom: childrenBottomPadding ?? childrenPadding ?? 0),
          iconColor: iconColor ?? AppPalettes.primaryColor,
          collapsedIconColor: iconColor ?? AppPalettes.primaryColor,
          backgroundColor: AppPalettes.whiteColor,
          collapsedBackgroundColor: AppPalettes.whiteColor,
          collapsedTextColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          
          subtitle: subtTitle == null
              ? null
              : Text(
                  subtTitle ?? "",
                  style:
                      subTitleTextStyle ??
                      context.textTheme.labelSmall?.copyWith(
                        fontSize: titleFontSize,
                      ),
                ).onlyPadding(top: Dimens.paddingX1),
          title: Text(
            title,
            style:
                textStyle ??
                context.textTheme.labelMedium?.copyWith(
                  fontSize: titleFontSize,
                ),
          ),
          children: children,
        ),
      ),
    );
  }
}
