import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';

class PartyHelpCard extends StatelessWidget {
  const PartyHelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX4,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX2,
        blurRadius: 2,
        spreadRadius: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Dimens.gapX1,
        children: [
          topWidget(textTheme),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              children: [
                TextSpan(text: localization.requested_amount),
                TextSpan(text: " : "),
                TextSpan(
                  text: "₹1000",
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              children: [
                TextSpan(text: localization.description),
                TextSpan(text: " : "),
                TextSpan(
                  text: "Medical Treatment",
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizeBox.size,
          Row(
            spacing: Dimens.gapX2,
            children: [
              Expanded(
                child: CommonButton(
                  onTap: () => RouteManager.pushNamed(Routes.contributePage),
                  text: localization.contribute,
                  height: 0,
                  fontSize: 14,
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.paddingX1,
                    horizontal: Dimens.paddingX2,
                  ),
                ),
              ),
              Expanded(
                child: CommonButton(
                  onTap: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return DraggableSheetWidget(
                        size: 0.5,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.horizontalspacing,
                            vertical: Dimens.paddingX2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Dimens.gapX2,
                            children: [
                              topWidget(textTheme),
                              getRow(
                                textTheme,
                                text: localization.requested_amount,
                                desc: "₹1000",
                              ),
                              getRow(
                                textTheme,
                                text: localization.urgency,
                                desc: "High",
                              ),
                              getRow(
                                textTheme,
                                text: localization.date_of_request,
                                desc: "01-09-2025",
                              ),
                              getRow(
                                textTheme,
                                text: localization.detailed_desc,
                                desc: "",
                              ),
                              Text(
                                "My mother requires urgent treatment for a chronic illness. We are unable to manage the hospital expenses and need financial help.",
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: AppPalettes.blackColor,
                                ),
                              ),
                              getRow(
                                textTheme,
                                text: localization.previous_contributions,
                                desc: "",
                              ),
                              Text(
                                '''• Amount contributed: ₹1000.
• Number of contributors: 2.
• Status: Partially Funded.''',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: AppPalettes.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  textColor: AppPalettes.primaryColor,
                  color: AppPalettes.liteGreyColor,
                  fontSize: 14,
                  elevation: 0.1,
                  text: localization.view_details,
                  height: 0,
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.paddingX1,
                    horizontal: Dimens.paddingX2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget topWidget(TextTheme textTheme) {
    return Row(
      spacing: Dimens.gapX2,
      children: [
        SizedBox(
          height: Dimens.scaleX6,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(Dimens.radius100)),
            child: CommonHelpers.getCacheNetworkImage(
              "https://media.gettyimages.com/id/164928990/photo/young-woman-portrait.jpg?s=612x612&w=0&k=20&c=c9tonf-iDbD5Ig85gsIZxZ_ws1nksxQBgeUwMs2_sKM=",
            ),
          ),
        ),
        Expanded(
          child: Column(
            spacing: Dimens.gapX,
            children: [
              Row(
                children: [
                  Text(
                    "Ravi Kumar",
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  CommonHelpers.buildStatus(
                    "Health",
                    statusColor: AppPalettes.greenColor,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: Dimens.gapX1,
                children: [
                  CommonHelpers.buildIcons(
                    path: AppImages.locationIcon,
                    iconSize: Dimens.scaleX2,
                  ),
                  Text("Hyderabad, Telangana", style: textTheme.labelMedium),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget getRow(TextTheme style, {required String text, String? desc}) {
  return RichText(
    text: TextSpan(
      style: style.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppPalettes.blackColor,
      ),
      children: [
        TextSpan(text: text),
        TextSpan(text: " : "),
        TextSpan(
          text: desc,
          style: style.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: AppPalettes.blackColor,
          ),
        ),
      ],
    ),
  );
}
