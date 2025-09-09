import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class CommonSearchDropDown<T> extends StatelessWidget {
  final String? Function(T?)? validator;
  final String heading;
  final String hintText;
  final bool isEnable;
  final bool labelText;
  final bool excludeSelected;
  final List<T>? items;
  final T? initialData;
  final SingleSelectController<T>? controller;
  final dynamic Function(T?)? onChanged;
  final Widget? prefixIcon;
  final Widget Function(BuildContext, T, bool, void Function())?
  listItemBuilder;
  final Widget Function(BuildContext, T, bool)? headerBuilder;
  final Future<List<T>> Function(String)? future;
  final bool? isRequired;

  static const border = Border.fromBorderSide(
    BorderSide(color: AppPalettes.transparentColor, width: 0.0),
  );
  static const errorBorder = Border.fromBorderSide(
    BorderSide(color: AppPalettes.redColor, width: 1),
  );

  const CommonSearchDropDown({
    super.key,
    required this.heading,
    required this.hintText,
    this.isEnable = true,
    this.items,
    this.controller,
    this.validator,
    this.onChanged,
    this.excludeSelected = true,
    this.initialData,
    this.labelText = true,
    this.listItemBuilder,
    this.headerBuilder,
    this.future,
    this.prefixIcon,
    this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$heading ${isRequired == true ? '*' : ''}",
          style: context.textTheme.bodySmall,
        ).onlyPadding(bottom: Dimens.gapX1B),
        CustomDropdown<T>.searchRequest(
          futureRequest: future,
          enabled: isEnable,
          overlayHeight: 0.4.screenHeight,
          closeDropDownOnClearFilterSearch: true,
          disabledDecoration: CustomDropdownDisabledDecoration(
            fillColor: AppPalettes.whiteColor,
          ),
          controller: controller,
          initialItem: initialData,
          headerBuilder: headerBuilder,
          noResultFoundBuilder: (context, text) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimens.paddingX8),
                child: Text("No places found !"),
              ),
            );
          },
          listItemBuilder: listItemBuilder,
          validator: validator,
          itemsListPadding: EdgeInsets.only(
            left: Dimens.paddingX4,
            right: Dimens.paddingX4,
            top: Dimens.paddingX4,
          ),
          closedHeaderPadding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX5,
            vertical: Dimens.paddingX3B,
          ),
          listItemPadding: EdgeInsets.only(bottom: Dimens.paddingX3),
          hideSelectedFieldWhenExpanded: true,
          searchHintText: "Enter location",
          decoration: CustomDropdownDecoration(
            searchFieldDecoration: SearchFieldDecoration(
              textStyle: context.textTheme.bodySmall,
            ),
            headerStyle: context.textTheme.bodySmall,
            listItemStyle: context.textTheme.bodySmall,
            hintStyle: context.textTheme.bodyMedium,
            errorStyle: AppStyles.errorStyle,
            prefixIcon: prefixIcon,
            closedErrorBorder: errorBorder,
            closedFillColor: AppPalettes.textFieldColor,
            closedBorderRadius: BorderRadius.circular(10),
            expandedBorderRadius: BorderRadius.circular(10),
            expandedBorder: border,
            closedBorder: border,
          ),
          hintText: hintText,
          hintBuilder: (context, hint, enabled) => Row(
            children: [
              SvgPicture.asset(AppImages.locationIcon),
              SizeBox.sizeWX3,
              Text(
                hintText,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
            ],
          ),
          items: items,
          excludeSelected: excludeSelected,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
