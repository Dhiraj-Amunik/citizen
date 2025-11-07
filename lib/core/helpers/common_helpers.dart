import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:share_plus/share_plus.dart';
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

  static Widget getCacheNetworkImage(
    String? image, {
    Widget? placeholder,
    BoxFit? fit,
  }) {
    return CachedNetworkImage(
      imageUrl: image ?? "",
      fit: fit ?? BoxFit.contain,
      progressIndicatorBuilder: (context, child, progress) {
        return shimmer();
      },
      errorWidget: (context, error, stackTrace) {
        return placeholder ??
            Container(
              color: AppPalettes.imageholderColor,
              child: Image.asset(
                AppImages.imagePlaceholder,
                fit: BoxFit.contain,
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
    double? radius,
  }) {
    return InkWell(
      customBorder: const CircleBorder(),
      overlayColor: const WidgetStatePropertyAll(
        AppPalettes.iconBackgroundColor,
      ),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? Dimens.radius100),
          color: color,
          border: Border.all(
            width: 1,
            color: borderColor ?? AppPalettes.transparentColor,
          ),
        ),
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
    double? opacity,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radius100,
        backgroundColor: statusColor.withOpacityExt(opacity ?? 0.2),
      ),
      child: Text(
        text,
        style: (textStyle ?? AppStyles.labelMedium).copyWith(
          color: textColor ?? AppPalettes.lightTextColor,
        ),
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

  static Future shareURL(String url) async {
    if (url == "") {
      CommonSnackbar(text: "No link found").showToast();
    }
    return SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
  }

  static Future shareImageUsingLink({
    required String url,
    String? description,
  }) async {
    if (url.showDataNull) {
      try {
        final network = NetworkRequester();
        final temp = "${await getTempPath() ?? ""}/image.png";
        final link = url;
        if (temp != "/image.png") {
          final response = await network.download(url: link);
          if (response != null) {
            File file = File(temp);
            var raf = file.openSync(mode: FileMode.write);
            raf.writeFromSync(response);
            await raf.close();
            return SharePlus.instance.share(
              ShareParams(
                files: [XFile(temp)],
                text: description,
                subject: 'Lok Varta',
              ),
            );
          }
        }
      } catch (err) {
        CommonSnackbar(text: "Unable to Download Image").showToast();
        return SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
      }
    } else {
      return CommonSnackbar(text: "No link found").showToast();
    }
  }
}
