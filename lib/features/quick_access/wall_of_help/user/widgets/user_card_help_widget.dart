import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_button.dart';

import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class UserCardHelpWidget extends StatelessWidget {
  final model.Data help;
  const UserCardHelpWidget({super.key, required this.help});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.widgetSpacing,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX3,
            vertical: Dimens.paddingX3,
          ),
          decoration: boxDecorationRoundedWithShadow(
            backgroundColor: AppPalettes.greenColor.withOpacityExt(0.2),
            Dimens.radiusX5,
            spreadRadius: 2,
            blurRadius: 2,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("A Family That Cares", style: textTheme.bodyMedium),
                  SizedBox(height: Dimens.gapX2),
                  Text(
                    "Beyond politics, we build trust and support. With the Wall of Help, you are never alone assistance is always near.",
                    style: textTheme.labelMedium,
                  ),
                  SizeBox.sizeHX8,
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CommonButton(
                  width: 120.w,
                  text: 'Join Party Member',
                  color: AppPalettes.buttonColor,
                ),
              ),
            ],
          ),
        ),

        Text('View how members Benefited ', style: textTheme.bodyLarge),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX3,
            vertical: Dimens.paddingX3,
          ),
          decoration: boxDecorationRoundedWithShadow(
            Dimens.radiusX5,
            spreadRadius: 2,
            blurRadius: 2,
            border: Border.all(color: AppPalettes.buttonColor),
          ),
          child: Column(
            spacing: Dimens.gapX2,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.paddingX5,
                      vertical: Dimens.paddingX,
                    ),
                    decoration: boxDecorationRoundedWithShadow(
                      Dimens.radiusX2,
                      backgroundColor: AppPalettes.greenColor.withOpacityExt(
                        0.2,
                      ),
                    ),
                    child: Text("Solved", style: textTheme.labelMedium),
                  ),
                ],
              ),
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
                        help.subject ?? "Unknow subject",
                        style: textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: Dimens.paddingX3,
                    //       vertical: Dimens.paddingX,
                    //     ),
                    //     decoration: boxDecorationRoundedWithShadow(
                    //       Dimens.radius100,
                    //       backgroundColor: AppPalettes.greenColor
                    //           .withOpacityExt(0.2),
                    //     ),
                    //     child: Text(
                    //       "Solved",
                    //       style: textTheme.labelMedium?.copyWith(
                    //         color: AppPalettes.greenColor,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 40.height()),
                child: RichText(
                  maxLines: 3,
                  text: TextSpan(
                    style: textTheme.bodySmall,
                    children: [
                      TextSpan(text: 'Reason : '),
                      TextSpan(
                        text: help.reason ?? "Unknown Reason",

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
                spacing: Dimens.gapX2,
                children: [
                  CommonHelpers.buildIcons(
                    path: AppImages.calenderIcon,
                    iconColor: context.iconsColor,
                    iconSize: Dimens.scaleX2,
                  ),
                  Text(
                    "Submitted : ${help.createdAt?.toDdMmYyyy()}",
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
