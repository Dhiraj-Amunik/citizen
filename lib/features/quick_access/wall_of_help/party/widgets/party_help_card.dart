import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class PartyHelpCard extends StatelessWidget {
  final model.Data helpRequest;

  const PartyHelpCard({super.key, required this.helpRequest});

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
          Row(
            spacing: Dimens.gapX2,
            children: [
              SizedBox(
                height: Dimens.scaleX6,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(Dimens.radius100),
                  ),
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
                          helpRequest.name ?? "Unknown name",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        CommonHelpers.buildStatus(
                          helpRequest.isActive == true ? "Pending" : "Resolved",
                          textColor: AppPalettes.lightTextColor,
                          statusColor: helpRequest.isActive == true
                              ? AppPalettes.yellowColor
                              : AppPalettes.greenColor,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: Dimens.gapX1,
                      children: [
                        CommonHelpers.buildIcons(
                          path: AppImages.calenderIcon,
                          iconSize: Dimens.scaleX1B,
                          iconColor: AppPalettes.blackColor,
                        ),
                        Text(
                          helpRequest.createdAt?.toDdMmmYyyy() ?? "",
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              children: [
                TextSpan(text: localization.requested_amount),
                TextSpan(text: " : "),
                TextSpan(
                  text: "₹${helpRequest.amountRequested}",
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
                  text: helpRequest.description,
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
                  onTap: () {
                    if (helpRequest.isActive == true &&
                        (helpRequest.amountCollected !=
                            helpRequest.amountRequested)) {
                      RouteManager.pushNamed(
                        Routes.contributePage,
                        arguments: helpRequest,
                      );
                      return;
                    }
                    CommonSnackbar(
                      text: "Amount has been raised successfully",
                    ).showToast();
                  },
                  text: localization.contribute,
                  height: 30.height(),
                  radius: Dimens.radiusX2,
                  padding: EdgeInsets.symmetric(vertical: Dimens.paddingX1),
                ),
              ),
              Expanded(
                child: CommonButton(
                  color: AppPalettes.whiteColor,
                  borderColor: AppPalettes.primaryColor,
                  onTap: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return DraggableSheetWidget(
                        size: 0.5,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.horizontalspacing,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Dimens.gapX1B,
                            children: [
                              getRow(
                                textTheme,
                                text: localization.requested_amount,
                                desc: "${helpRequest.amountRequested ?? 'Nil'}",
                              ),
                              getRow(
                                textTheme,
                                text: localization.raised_amount,
                                desc: "${helpRequest.amountCollected ?? 'Nil'}",
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
                                desc: helpRequest.description,
                              ),
                              // getRow(
                              //   textTheme,
                              //   text: localization.previous_contributions,
                              //   desc: helpRequest.transactions?.isEmpty == true
                              //       ? ''
                              //       : "Total ${helpRequest.transactions?.length} users have contributed",
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  textColor: AppPalettes.primaryColor,
                  text: localization.view_details,
                  height: 30.height(),
                  radius: Dimens.radiusX2,
                  padding: EdgeInsets.symmetric(vertical: Dimens.paddingX1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getRow(TextTheme style, {required String text, String? desc}) {
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
            style: style.labelLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: AppPalettes.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
