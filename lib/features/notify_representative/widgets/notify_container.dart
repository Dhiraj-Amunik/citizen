import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';

class NotifyContainer extends StatelessWidget {
  final NotifyRepresentative model;
  final Function? onDelete;
  const NotifyContainer({super.key, this.onDelete, required this.model});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      width: double.infinity,
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX3,
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: Dimens.gapX2,
            children: [
              CommonHelpers.buildStatus(
                model.dateAndTime?.toRelativeTime() ?? "",
                statusColor: AppPalettes.liteBlueColor,
              ),
              CommonHelpers.buildStatus(
                model.isDeleted == true
                    ? "Closed"
                    : model.isActive == true
                    ? "Pending"
                    : "Completed",
                textColor: AppPalettes.blackColor,
                statusColor: model.isDeleted == true
                    ? AppPalettes.redColor
                    : model.isActive == true
                    ? AppPalettes.yellowColor
                    : AppPalettes.greenColor,
              ),
            ],
          ),
          SizeBox.sizeHX1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimens.gapX,
            children: [
              Text(
                model.title?.capitalize() ?? "Unknown Title",
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: Dimens.gapX1,
                children: [
                  CommonHelpers.buildIcons(
                    path: AppImages.locationIcon,
                    iconSize: Dimens.scaleX1B,
                    iconColor: AppPalettes.blackColor,
                  ),
                  Text(model.location ?? "  ", style: textTheme.bodySmall),
                ],
              ),
              ReadMoreWidget(
                text: model.description.isNull(localization.not_found),
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
            ],
          ),
          SizeBox.sizeHX2,
          if (onDelete != null)
            Row(
              spacing: Dimens.gapX2,
              children: [
                Expanded(
                  child: CommonButton(
                    onTap: onDelete,
                    color: AppPalettes.whiteColor,
                    borderColor: AppPalettes.primaryColor,
                    textColor: AppPalettes.primaryColor,
                    text: localization.delete,
                    height: 40,
                    padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                    radius: Dimens.radiusX2,
                  ),
                ),
                Expanded(
                  child: CommonButton(
                    onTap: () => RouteManager.pushNamed(
                      Routes.updateNotifyRepresentativePage,
                      arguments: model,
                    ),
                    text: localization.edit,
                    height: 40,
                    padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                    radius: Dimens.radiusX2,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
