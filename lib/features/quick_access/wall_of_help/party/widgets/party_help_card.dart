import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class PartyHelpCard extends StatelessWidget {
  final bool isEditable;
  final Function? closeRequest;
  final model.FinancialRequest helpRequest;

  const PartyHelpCard({
    super.key,
    required this.helpRequest,
    this.isEditable = false,
    this.closeRequest,
  });

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final bool isFinancialHelp =
        [
          "Financial",
        ].contains(helpRequest.preferredWayForHelp?.name?.split(" ")[0]) ==
        true;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX4,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        blurRadius: 2,
        spreadRadius: 2,
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Dimens.gapX1,
        children: [
          Column(
            spacing: Dimens.gapX1,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      helpRequest.name.isNull(localization.not_found),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizeBox.sizeWX2,

                  CommonHelpers.buildStatus(
                    helpRequest.preferredWayForHelp?.name?.capitalize().isNull(
                          localization.not_found,
                        ) ??
                        localization.not_found,
                    textColor: AppPalettes.blackColor,
                    statusColor: AppPalettes.greenColor,
                  ),
                  if (isEditable) SizeBox.sizeWX2,
                  if (isEditable)
                    CommonHelpers.buildStatus(
                      helpRequest.status
                          .isNull(localization.not_found)
                          .capitalize(),
                      textColor: AppPalettes.blackColor,
                      statusColor: helpRequest.status == "rejected"
                          ? AppPalettes.liteRedColor
                          : helpRequest.status == "pending"
                          ? AppPalettes.liteOrangeColor
                          : helpRequest.status == "closed"
                          ? AppPalettes.liteGreyColor
                          : AppPalettes.yellowColor,
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
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(
                color: AppPalettes.lightTextColor,
              ),
              children: [
                TextSpan(text: localization.requested),
                TextSpan(text: " : "),
                TextSpan(
                  text: isFinancialHelp
                      ? "₹ ${helpRequest.amountRequested}"
                      : helpRequest.typeOfHelp?.name,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppPalettes.blackColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${localization.description} : ",
                style: textTheme.bodySmall?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
              Expanded(
                child: ReadMoreWidget(
                  text: helpRequest.description.isNull(localization.not_found),
                  style: AppStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizeBox.size,
          Row(
            spacing: Dimens.gapX2,
            children: [
              Expanded(
                flex: isEditable && helpRequest.status != "closed" ? 8 : 1,
                child: CommonButton(
                  onTap: () => RouteManager.pushNamed(
                    Routes.wallOfHelpDetailsPage,
                    arguments: {"model": helpRequest, "isEditable": isEditable},
                  ),
                  borderColor: AppPalettes.primaryColor,
                  color: AppPalettes.whiteColor,
                  textColor: AppPalettes.primaryColor,
                  text: localization.view_details,
                  height: 30.height(),
                  fullWidth: false,
                  radius: Dimens.radiusX4,
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.paddingX1,
                    horizontal: Dimens.paddingX2,
                  ),
                ),
              ),
              if (helpRequest.status != "closed")
                Expanded(
                  flex: isEditable ? 10 : 1,
                  child: Row(
                    spacing: Dimens.gapX2,
                    children: [
                      if (isEditable == false || isFinancialHelp == false)
                        Expanded(
                          child: CommonButton(
                            borderColor:
                                isEditable && helpRequest.status != "rejected"
                                ? AppPalettes.primaryColor
                                : null,
                            color: isEditable ? AppPalettes.whiteColor : null,
                            textColor:
                                isEditable && helpRequest.status != "rejected"
                                ? AppPalettes.primaryColor
                                : null,
                            onTap: () {
                              if (isFinancialHelp) {
                                if (helpRequest.isActive == true &&
                                    (helpRequest.amountCollected !=
                                        helpRequest.amountRequested)) {
                                  RouteManager.pushNamed(
                                    Routes.contributePage,
                                    arguments: helpRequest,
                                  );
                                } else {
                                  CommonSnackbar(
                                    text: "Amount has been raised successfully",
                                  ).showToast();
                                }
                              } else {
                                if (helpRequest.isActive == true) {
                                  if (isEditable) {
                                    RouteManager.pushNamed(
                                      Routes.myHelpMessagesListPage,
                                      arguments: helpRequest,
                                    );
                                  } else {
                                    RouteManager.pushNamed(
                                      Routes.chatContributePage,
                                      arguments: helpRequest,
                                    );
                                  }
                                }
                              }
                            },
                            text: isFinancialHelp
                                ? localization.contribute
                                : localization.chat,
                            isEnable: helpRequest.status == "rejected"
                                ? false
                                : true,
                            disabledColor: AppPalettes.greyColor,
                            height: 30.height(),
                            radius: Dimens.radiusX4,
                            padding: EdgeInsets.symmetric(
                              vertical: Dimens.paddingX1,
                              horizontal: Dimens.paddingX2,
                            ),
                            fullWidth: false,
                          ),
                        ),
                      if (isEditable && helpRequest.status != "closed")
                        Expanded(
                          child: CommonButton(
                            onTap: () => RouteManager.pushNamed(
                              Routes.myHelpRequestEditPage,
                              arguments: helpRequest,
                            ),
                            isEnable: helpRequest.status == "rejected"
                                ? false
                                : true,
                            disabledColor: AppPalettes.greyColor,
                            color: helpRequest.status == "rejected"
                                ? AppPalettes.greyColor
                                : null,
                            text: localization.edit,
                            height: 30.height(),
                            fullWidth: false,
                            radius: Dimens.radiusX4,
                            padding: EdgeInsets.symmetric(
                              vertical: Dimens.paddingX1,
                              horizontal: Dimens.paddingX2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),

          if (isEditable && helpRequest.status != "closed") SizeBox.size,

          if (isEditable && helpRequest.status != "closed")
            CommonButton(
              onTap: closeRequest,
              text: "Close Request",
              height: 32.height(),
              radius: Dimens.radiusX4,
              padding: EdgeInsets.symmetric(
                vertical: Dimens.paddingX1,
                horizontal: Dimens.paddingX2,
              ),
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
