import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final bool? showCursor;
  final String? hintText;

  final TextStyle? textStyle;
  final TextStyle? headingStyle;
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
  final VoidCallback? onComplete;
  final String? headingText;
  final String? labelText;
  final Color borderColor;
  final double borderWidth;
  final double? radius;
  final Color? cursorColor;
  final Color? fillColor;
  final bool? alignLabel;
  final double? fontSize;
  final double elevation;
  final Color? backgroundColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry? contentPadding;
  final String? initialValue;
  final bool? showCounterText;
  final bool? isRequired;

  const FormTextFormField({
    super.key,
    this.onTap,
    this.controller,
    this.hintText,
    this.textStyle,
    this.headingStyle,
    this.showCursor = true,
    this.maxLength,
    this.headingText,
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

    //Material
    this.elevation = 0.0,
    this.backgroundColor = AppPalettes.whiteColor,
    this.shadowColor,
    this.contentPadding,
    this.showCounterText,
    this.onComplete,
    this.labelStyle,
    this.labelText,
    this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    final respRadius = radius ?? Dimens.radiusX2;
    final border = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(respRadius),
    );
    final iconColor = ColorFilter.mode(context.iconsColor, BlendMode.srcIn);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headingText != null)
          Text(
            "${headingText!} ${isRequired ==true?'*':''}",
            style: headingStyle ?? context.textTheme.bodySmall,
          ).onlyPadding(bottom: Dimens.gapX1B),
        TextFormField(
          initialValue: initialValue,
          showCursor: showCursor,
          cursorColor: cursorColor,
          cursorErrorColor: cursorColor,
          onTap: onTap,
          maxLength: maxLength,
          cursorHeight: Dimens.paddingX5,
          style: textStyle ?? context.textTheme.bodySmall,
          focusNode: focus,
          enabled: enabled,
          keyboardType: keyboardType,
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            alignLabelWithHint: alignLabel,
            counterText: showCounterText == true ? null : "",
            counterStyle: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(
                  vertical: Dimens.paddingX3,
                  horizontal: Dimens.paddingX4,
                ),
            labelText: labelText,
            labelStyle: labelStyle ?? context.textTheme.bodySmall,
            hintText: hintText,
            hintStyle:
                textStyle ??
                context.textTheme.labelLarge?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
            errorStyle: AppStyles.errorStyle,
            border: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppPalettes.blackColor),
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
                    left: Dimens.paddingX4,
                    right: Dimens.paddingX2,
                    top: Dimens.paddingX4,
                    bottom: Dimens.paddingX3B,
                  )
                : null,

            suffixIcon: suffixIcon != null
                ? SvgPicture.asset(
                    suffixIcon!,
                    colorFilter: iconColor,
                  ).onlyPadding(
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
          onEditingComplete: onComplete,
          onFieldSubmitted: (submitValue) {
            FocusScope.of(context).requestFocus(nextFocus);
          },
        ),
      ],
    );
  }
}
