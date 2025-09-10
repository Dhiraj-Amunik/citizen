import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';

class ComplaintThreadWidget extends StatelessWidget {
  final Data thread;
  final VoidCallback onTap;

  const ComplaintThreadWidget({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radiusX2),
      child: Container(
        padding: EdgeInsetsGeometry.all(Dimens.paddingX4),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          border: Border.all(color: AppPalettes.primaryColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimens.gapX2,
          children: [
            IntrinsicHeight(
              child: Row(
                spacing: Dimens.gapX3,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: CommonHelpers.buildIcons(
                      color: AppPalettes.liteGreenTextFieldColor,
                      path: AppImages.emailIcon,
                      iconColor: AppPalettes.primaryColor,
                      iconSize: Dimens.scaleX1B,
                      padding: Dimens.paddingX2B,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      thread.messages?.first.subject ?? "No Subject found !",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.paddingX3,
                        vertical: Dimens.paddingX,
                      ),
                      decoration: boxDecorationRoundedWithShadow(
                        Dimens.radius100,
                        backgroundColor:
                            (thread.isActive == true
                                    ? AppPalettes.yellowColor
                                    : AppPalettes.blueColor)
                                .withOpacityExt(0.2),
                      ),
                      child: Text(
                        thread.isActive == true ? "Pending" : "Resolved",
                        style: textTheme.labelMedium?.copyWith(
                          color: AppPalettes.lightTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 40.height()),
              child: RichText(
                text: TextSpan(
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: "Message : "),
                    TextSpan(
                      text:
                          thread.messages?.first.snippet ??
                          "Unknown Description",
                      style: textTheme.labelMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: Dimens.gapX2,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonHelpers.buildIcons(
                      path: AppImages.calenderIcon,
                      iconColor: context.iconsColor,
                      iconSize: Dimens.scaleX2,
                    ),
                    Text(
                      thread.messages?.first.date?.toDdMmmYyyy() ?? "",
                      style: textTheme.labelMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.email, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '0 messages',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
