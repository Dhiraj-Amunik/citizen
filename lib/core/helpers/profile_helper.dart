import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class ProfileHelper {
  static Widget getProfileBox({
    required String? image,
    required String? name,
    required String? number,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.radiusX2),
      overlayColor: const WidgetStatePropertyAll(AppPalettes.liteGreyColor),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX3,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX5,
          backgroundColor: AppPalettes.liteGreyColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                height: Dimens.scaleX7,
                width: Dimens.scaleX7,
                color: AppPalettes.whiteColor,
                child: CommonHelpers.getCacheNetworkImage(
                  image,
                  placeholder: CommonHelpers.showInitials(
                    name ?? '',
                    style: AppStyles.bodyLarge,
                  ),
                ),
              ),
            ),
            SizeBox.sizeWX4,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? "",
                    style: AppStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (number != null)
                    Text(
                      number,
                      style: AppStyles.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.edit_square,
              size: Dimens.scaleX3,
              color: AppPalettes.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  static Widget getCommonBox(
    String text, {
    String? subtext,
    VoidCallback? onTap,
    required String icon,
    Color? iconColor = AppPalettes.primaryColor,
    Color backgroundColor = AppPalettes.liteGreyColor,
    bool showArrow = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.radiusX2),
      overlayColor: const WidgetStatePropertyAll(AppPalettes.transparentColor),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX3,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          backgroundColor: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonHelpers.buildIcons(
              color: AppPalettes.whiteColor,
              padding: Dimens.paddingX2B,
              path: icon,
              iconColor: iconColor,
              iconSize: Dimens.scaleX2,
              borderColor: AppPalettes.transparentColor,
            ),
            SizeBox.sizeWX4,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppStyles.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtext != null)
                    Text(
                      subtext,
                      style: AppStyles.labelMedium.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizeBox.sizeWX4,
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: Dimens.scaleX2,
                color: AppPalettes.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  static Widget getLogout(String text, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.radiusX2),
      overlayColor: const WidgetStatePropertyAll(AppPalettes.transparentColor),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX3,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          backgroundColor: AppPalettes.whiteColor,
          border: Border.all(color: AppPalettes.redColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonHelpers.buildIcons(
              color: AppPalettes.redColor.withOpacityExt(0.2),
              padding: Dimens.paddingX2,
              path: AppImages.logout,
              iconColor: AppPalettes.redColor,
              iconSize: Dimens.scaleX2B,
              borderColor: AppPalettes.transparentColor,
            ),
            SizeBox.sizeWX4,
            Text(
              text,
              style: AppStyles.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static Widget getProfileIcon(
    double size,
    String icons, {
    Color? iconColor,
    Color? iconBackgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size / 3.5),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? AppPalettes.greyColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        icons,
        fit: BoxFit.fitWidth,
        colorFilter: ColorFilter.mode(
          iconColor ?? AppPalettes.primaryColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  static Widget getDetails(
    String heading, {
    String? text,
    double? hFontSize,
    double? tFontSize,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: AppStyles.bodyMedium),

        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppPalettes.primaryColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(text ?? '', style: AppStyles.bodyMedium),
          ),
        ),
      ],
    );
  }

  static Widget getText(
    String heading, {
    double? hFontSize,
    required Widget child,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: AppStyles.bodyMedium),
        child,
      ],
    );
  }
}
