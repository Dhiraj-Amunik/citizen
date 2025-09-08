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

class CommonDropDown<T> extends StatelessWidget {
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

  const CommonDropDown({
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
  });

  @override
  Widget build(BuildContext context) {
    final respRadius = radius ?? Dimens.radiusX2;
    final border = Border.fromBorderSide(BorderSide.none);
    final iconColor = ColorFilter.mode(context.iconsColor, BlendMode.srcIn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading?.isEmpty == true)
          Text(
            heading!,
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
            horizontal: Dimens.paddingX5,
            vertical: Dimens.paddingX4,
          ),
          listItemPadding: EdgeInsets.only(bottom: Dimens.paddingX3),
          expandedHeaderPadding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX5,
            vertical: Dimens.paddingX3B,
          ),
          decoration: CustomDropdownDecoration(
            headerStyle: context.textTheme.bodyMedium,
            listItemStyle: context.textTheme.bodyMedium,
            hintStyle: context.textTheme.bodyMedium,
            errorStyle: AppStyles.errorStyle,
            prefixIcon: prefixIcon != null
                ? SvgPicture.asset(
                    prefixIcon!,
                    colorFilter: iconColor,
                    height: 22.spMax,
                  ).onlyPadding(right: Dimens.paddingX1)
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
          hintText: 'Select $hintText',

          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
