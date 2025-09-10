import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:flutter/material.dart';

BoxDecoration boxDecorationRoundedWithShadow(
  double radius, {
  bool disableBottomRadius = false,
  bool disabletopRadius = false,
  Color backgroundColor = AppPalettes.whiteColor,
  Color? shadowColor = AppPalettes.liteGreyColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
  LinearGradient? gradient,
  BoxBorder? border,
}) {
  return BoxDecoration(
    boxShadow: defaultBoxShadow(
      shadowColor: shadowColor ?? AppPalettes.liteGreyColor.withOpacityExt(0.2),
      blurRadius: blurRadius ?? 0.0,
      spreadRadius: spreadRadius ?? 0,
      offset: offset,
    ),
    color: backgroundColor,
    gradient: gradient,
    borderRadius: disabletopRadius
        ? bottomRadius(radius)
        : disableBottomRadius
        ? topRadius(radius)
        : radiusAll(radius),
    border: border,
  );
}

/// default box shadow
List<BoxShadow> defaultBoxShadow({
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
}) {
  return [
    BoxShadow(
      color: shadowColor ?? Colors.grey.withOpacityExt(0.2),
      blurRadius: blurRadius ?? 4.0,
      spreadRadius: spreadRadius ?? 1.0,
      offset: offset,
    ),
  ];
}

BorderRadius radiusAll([double? radius]) {
  return BorderRadius.all(radiusCircular(radius ?? 8.0));
}

BorderRadius topRadius([double? radius]) {
  return BorderRadius.only(
    topLeft: radiusCircular(radius ?? 8.0),
    topRight: radiusCircular(radius ?? 8.0),
  );
}

BorderRadius bottomRadius([double? radius]) {
  return BorderRadius.only(
    bottomLeft: radiusCircular(radius ?? 8.0),
    bottomRight: radiusCircular(radius ?? 8.0),
  );
}

/// returns Radius
Radius radiusCircular([double? radius]) {
  return Radius.circular(radius ?? 8.0);
}
