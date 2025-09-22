import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class UserCardHelpWidget extends StatelessWidget {
  final model.Data help;
  const UserCardHelpWidget({super.key, required this.help});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        border: BoxBorder.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        spacing: Dimens.gapX2,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              spacing: Dimens.gapX3,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppPalettes.blackColor,
                  radius: Dimens.radiusX6,
                ),
                Expanded(
                  child: Text(
                    help.title ?? "Unknow subject",
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                      backgroundColor: AppPalettes.greenColor.withOpacityExt(
                        0.2,
                      ),
                    ),
                    child: Text(
                      help.createdAt?.toDdMmmYyyy()??"Pending",
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
                style: textTheme.bodySmall,
                children: [
                  TextSpan(text: 'Reason : '),
                  TextSpan(
                    text: help.description ?? "Unknown Reason",
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
            spacing: Dimens.gapX1B,
            children: [
              CommonHelpers.buildIcons(
                path: AppImages.calenderIcon,
                iconColor: context.iconsColor,
                iconSize: Dimens.scaleX1B,
              ),
              Text(
                "Submitted : ${help.createdAt?.toDdMmmYyyy()}",
                style: textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
