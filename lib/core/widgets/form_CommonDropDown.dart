import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:flutter/cupertino.dart';

class FormCommonDropDown<T> extends StatelessWidget {
  final String? Function(T?)? validator;
  final String? heading;
  final String? hintText;
  final SingleSelectController<T>? controller;
  final List<T>? items;
  final T? initialData;
  final dynamic Function(T?)? onChanged;
  final String? prefixIcon;
  final Widget Function(BuildContext, T, bool, void Function())?
  listItemBuilder;
  final Widget Function(BuildContext, T, bool)? headerBuilder;
  final double? radius;
  final Color? backgroundColor;
  final bool? isRequired;
  final bool excludeSelected;

  const FormCommonDropDown({
    super.key,
    this.heading,
    this.hintText,
    this.items,
    this.validator,
    this.controller,
    this.onChanged,
    this.headerBuilder,
    this.listItemBuilder,
    this.prefixIcon,
    this.initialData,
    this.radius,
    this.backgroundColor = AppPalettes.whiteColor,
    this.isRequired,
    this.excludeSelected=true,
  });

  @override
  Widget build(BuildContext context) {
    final respRadius = radius ?? Dimens.radiusX4;
    final border = Border.fromBorderSide(BorderSide.none);
    final iconColor = ColorFilter.mode(context.iconsColor, BlendMode.srcIn);
    final effectiveItems = items ?? const [];

    // Only clear controller value if items list is not empty and value is not found
    // This prevents clearing when items are still loading or empty
    // This was causing assembly constituency to be cleared even when selected
    if (controller != null && 
        controller!.value != null && 
        effectiveItems.isNotEmpty) {
      final currentValue = controller!.value;
      final hasMatch = effectiveItems.contains(currentValue);
      if (!hasMatch) {
        controller!.clear();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading?.isNotEmpty == true)
          Text(
            "${heading!} ${isRequired ==true?'*':''}",
            style: context.textTheme.bodySmall,
          ).onlyPadding(bottom: Dimens.gapX1B),
        CustomDropdown<T>(
          overlayHeight: Dimens.screenHeight / 3,
          controller: controller,
          initialItem: initialData,
          headerBuilder: headerBuilder,
          listItemBuilder: listItemBuilder,
          itemsListPadding: EdgeInsets.only(
            left: Dimens.paddingX5,
            right: Dimens.paddingX5,
          ),
          closedHeaderPadding: EdgeInsets.symmetric(
            vertical: Dimens.paddingX3,
            horizontal: Dimens.paddingX4,
          ),
          listItemPadding: EdgeInsets.only(bottom: Dimens.paddingX3),
          expandedHeaderPadding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX5,
            vertical: Dimens.paddingX3B,
          ),
          decoration: CustomDropdownDecoration(
            headerStyle: context.textTheme.bodySmall,
            listItemStyle: context.textTheme.bodySmall,
            hintStyle: context.textTheme.labelLarge?.copyWith(
              color: AppPalettes.lightTextColor,
            ),
            errorStyle: AppStyles.errorStyle,
            prefixIcon: prefixIcon != null
                ? SvgPicture.asset(
                    prefixIcon!,
                    colorFilter: iconColor,
                    height: 22.spMax,
                  ).onlyPadding(left: Dimens.paddingX1B)
                : null,
            closedFillColor: AppPalettes.liteGreyColor,
            expandedFillColor: backgroundColor,
            closedBorderRadius: BorderRadius.circular(respRadius),
            expandedBorderRadius: BorderRadius.circular(respRadius),
            closedErrorBorderRadius: BorderRadius.circular(respRadius),
            closedErrorBorder: Border.fromBorderSide(
              BorderSide(width: 1, color: AppPalettes.redColor),
            ),
            expandedBorder: border,
            closedBorder: border,
          ),
          hintText: hintText,
          items: effectiveItems,
          excludeSelected: excludeSelected,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
