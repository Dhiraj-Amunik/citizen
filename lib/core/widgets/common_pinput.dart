import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class CommonPinput extends StatelessWidget {
  final TextEditingController controller;
  final int length;
  final BoxDecoration? decoration;
  final double? radius;
  final Color? color;
  final bool? showCursor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? Function(String?)? validator;
  final String? errorText;

  const CommonPinput({
    super.key,
    required this.controller,
    required this.length,
    this.decoration,
    this.radius,
    this.color,
    this.showCursor,
    this.padding,
    this.margin,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final width = 0.125.screenWidth;
    return Pinput(
      mainAxisAlignment: MainAxisAlignment.center,

      controller: controller,
      showCursor: showCursor ?? true,
      length: length,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      defaultPinTheme: PinTheme(
        width: width,
        height: width,
        textStyle: context.textTheme.bodyMedium,
        decoration:
            decoration ??
            boxDecorationRoundedWithShadow(
              radius ?? Dimens.radiusX2,
              backgroundColor: color ?? AppPalettes.liteGreenTextFieldColor,
            ),
        padding: padding,
        margin: margin,
      ),
      focusedPinTheme: PinTheme(
        textStyle: context.textTheme.bodyMedium,
        width: width,
        height: width,
        decoration:
            decoration ??
            boxDecorationRoundedWithShadow(
              radius ?? Dimens.radiusX2,
              backgroundColor: AppPalettes.whiteColor,
              border: Border.all(width: 1, color: AppPalettes.primaryColor),
            ),
        padding: padding,
        margin: margin,
      ),
      errorPinTheme: PinTheme(
        width: width,
        height: width,
        decoration: boxDecorationRoundedWithShadow(
          radius ?? Dimens.radiusX2,
          backgroundColor: AppPalettes.redColor.withOpacityExt(0.2),
        ),
        padding: padding,
        margin: margin,
      ),
      validator: validator,
      errorText: errorText,
      errorTextStyle: AppStyles.errorStyle,
    );
  }
}
