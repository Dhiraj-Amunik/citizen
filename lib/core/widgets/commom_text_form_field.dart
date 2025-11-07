import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final bool? showCursor;
  final String? hintText;

  final TextStyle? textStyle;
  final TextStyle? labelStyle;

  final int? maxLines;
  final int? maxLength;
  final bool isPassword;
  final bool enabled;
  final String? suffixIcon;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final FocusNode? focus;
  final FocusNode? nextFocus;
  final String? prefixIcon;
  final void Function(String?)? onChanged;
  final TextInputType? keyboardType;
  final Function()? onTap;
  final String? labelText;
  final Color borderColor;
  final double borderWidth;
  final double? radius;
  final Color? cursorColor;
  final Color? fillColor;
  final bool? alignLabel;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry? contentPadding;
  final String? initialValue;
  final Color? suffixColor;

  const CommonTextFormField({
    super.key,
    this.onTap,
    this.controller,
    this.hintText,
    this.textStyle,
    this.labelStyle,
    this.showCursor = true,
    this.maxLength,
    this.labelText,
    this.radius,
    this.cursorColor = AppPalettes.blackColor,
    this.borderColor = AppPalettes.primaryColor,
    this.borderWidth = 1,
    this.maxLines = 1,
    this.prefixIcon,
    this.alignLabel = false,
    this.keyboardType = TextInputType.emailAddress,
    this.isPassword = false,
    this.focus,
    this.enabled = true,
    this.nextFocus,
    this.onChanged,
    this.suffixIcon,
    this.suffixWidget,
    this.validator,
    this.fillColor,
    this.fontSize,
    this.initialValue,
    this.suffixColor,

    //Material
    this.backgroundColor,
    this.shadowColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final respRadius = radius ?? Dimens.radiusX4;
    final border = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(respRadius),
    );
    final iconColor = ColorFilter.mode(
      suffixColor ?? context.iconsColor,
      BlendMode.srcIn,
    );
    return TextFormField(
      initialValue: initialValue,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorErrorColor: cursorColor,
      onTap: onTap,
      maxLength: maxLength,
      cursorHeight: Dimens.paddingX5,
      style: textStyle ?? context.textTheme.bodyMedium,
      focusNode: focus,
      enabled: enabled,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        fillColor: backgroundColor == null
            ? null
            : WidgetStateColor.resolveWith((states) {
                return states.contains(WidgetState.focused)
                    ? AppPalettes.whiteColor
                    : backgroundColor!;
              }),
        labelText: labelText,
        labelStyle: labelStyle,
        isDense: true,
        filled: true,

        alignLabelWithHint: alignLabel,
        counterText: "",
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(
              vertical: Dimens.paddingX3,
              horizontal: Dimens.paddingX5,
            ),
        hintText: hintText,
        hintStyle:
            textStyle ??
            context.textTheme.bodyMedium?.copyWith(
              color: AppPalettes.lightTextColor,
            ),
        errorStyle: AppStyles.errorStyle,
        border: border,
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppPalettes.primaryColor),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppPalettes.redColor),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppPalettes.redColor),
        ),

        prefixIcon: prefixIcon != null
            ? SvgPicture.asset(
                prefixIcon!,
                colorFilter: iconColor,
                height: 0,
              ).onlyPadding(
                left: Dimens.paddingX5,
                right: Dimens.paddingX2,
                top: Dimens.paddingX4,
                bottom: Dimens.paddingX3B,
              )
            : null,

        suffixIcon: suffixIcon != null
            ? SvgPicture.asset(suffixIcon!, colorFilter: iconColor).onlyPadding(
                left: Dimens.paddingX2,
                right: Dimens.paddingX4,
                top: Dimens.paddingX3B,
                bottom: Dimens.paddingX3B,
              )
            : suffixWidget,
      ),
      
      maxLines: maxLines,
      obscureText: isPassword,
      obscuringCharacter: '.',
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: (submitValue) {
        FocusScope.of(context).requestFocus(nextFocus);
      },
    );
  }
}
