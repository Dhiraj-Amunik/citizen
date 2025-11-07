import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';

import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class UserCardHelpWidget extends StatelessWidget {
  final model.FinancialRequest help;
  const UserCardHelpWidget({super.key, required this.help});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonHelpers.buildStatus(
                help.status?.capitalize() ?? "Pending",
                statusColor: AppPalettes.liteGreenColor,
              ),
            ],
          ),
          Row(
            spacing: Dimens.gapX3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(Dimens.radius100),
                  child: help.partyMember?.user?.avatar.showDataNull == true
                      ? Container(
                          alignment: Alignment.center,
                          color: AppPalettes.greyColor,
                          child: Text(
                            CommonHelpers.getInitials(help.name ?? ""),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : CommonHelpers.getCacheNetworkImage(
                          help.partyMember?.user?.avatar,
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      help.title ?? "Unknow subject",
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizeBox.sizeHX1,
                    ReadMoreWidget(
                      text: help.description.isNull(localization.not_found),
                      style:AppStyles.labelMedium.copyWith(
                        color: AppPalettes.lightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizeBox.sizeHX1,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
