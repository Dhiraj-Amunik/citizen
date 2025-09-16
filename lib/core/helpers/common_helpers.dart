import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

class CommonHelpers {
  static Widget shimmer({double? radius}) {
    return Shimmer.fromColors(
      baseColor: AppPalettes.liteGreyColor,
      highlightColor: AppPalettes.whiteColor,
      child: Container(
        decoration: boxDecorationRoundedWithShadow(
          radius ?? 0,
          backgroundColor: AppPalettes.whiteColor,
        ),
      ),
    );
  }

  static Widget showInitials(
    String initials, {
    TextStyle? style,
    Color? color,
  }) {
    return Center(child: Text(getInitials(initials), style: style));
  }

  static Widget getCacheNetworkImage(String? image, {Widget? placeholder}) {
    return CachedNetworkImage(
      imageUrl: image ?? "",
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, child, progress) {
        return shimmer();
      },
      errorWidget: (context, error, stackTrace) {
        return placeholder ??
            Container(
              color: AppPalettes.backGroundColor,
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppPalettes.redColor,
                size: Dimens.scaleX2,
              ),
            );
      },
    );
  }

  static Widget buildIcons({
    required String path,
    double? iconSize,
    Function()? onTap,
    Color? iconColor,
    Color? color,
    Color? borderColor,
    double? padding,
  }) {
    return Container(
      padding: EdgeInsets.all(padding ?? 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          width: 1,
          color: borderColor ?? AppPalettes.transparentColor,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        overlayColor: const WidgetStatePropertyAll(
          AppPalettes.iconBackgroundColor,
        ),
        onTap: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: path.endsWith('.svg')
              ? SvgPicture.asset(
                  path,
                  height: iconSize,
                  colorFilter: iconColor == null
                      ? null
                      : ColorFilter.mode(iconColor, BlendMode.srcIn),
                )
              : Image.asset(path, height: iconSize, color: iconColor),
        ),
      ),
    );
  }

  static Widget buildStatus(
    String text, {
    required Color statusColor,
    Color? textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radius100,
        backgroundColor: statusColor.withOpacityExt(0.2),
      ),
      child: Text(
        text,
        style: AppStyles.labelMedium.copyWith(color: textColor),
      ),
    );
  }

  static Widget getRow(TextTheme style, {required String text, String? desc}) {
    return RichText(
      text: TextSpan(
        style: style.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppPalettes.blackColor,
        ),
        children: [
          TextSpan(text: text),
          TextSpan(text: " : "),
          TextSpan(
            text: desc,
            style: style.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppPalettes.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  static String getInitials(String name) {
    return name
        .split(" ")
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0])
        .join()
        .toUpperCase();
  }
}
