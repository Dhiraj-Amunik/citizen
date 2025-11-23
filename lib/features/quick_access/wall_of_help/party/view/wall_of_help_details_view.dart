import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/responisve_image_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class WallOfHelpDetailsView extends StatelessWidget {
  final model.FinancialRequest helpRequest;
  final bool isEditable;
  const WallOfHelpDetailsView({
    super.key,
    required this.helpRequest,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    final bool isFinancialHelp =
        [
          "Financial",
        ].contains(helpRequest.preferredWayForHelp?.name?.split(" ")[0]) ==
        true;
    return Scaffold(
      appBar: commonAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
          child: Column(
            children: [
              SizedBox(
                width: 0.8.screenWidth,
                child: TranslatedText(
                  text: helpRequest.typeOfHelp?.name?.capitalize() ?? "",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              SizeBox.sizeHX,
              ReadMoreWidget(maxLines: 4, text: helpRequest.description ?? ""),
              SizeBox.sizeHX2,

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX4,
                  vertical: Dimens.paddingX4,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX4,
                  backgroundColor: AppPalettes.liteGreenColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TranslatedText(
                      text: localization.urgency_level,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                    TranslatedText(
                      text: helpRequest.urgency ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    TranslatedText(
                      text: localization.preferred_way_to_receive_help,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: helpRequest.preferredWayForHelp?.name ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    TranslatedText(
                      text: localization.name,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: helpRequest.name ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,

                    TranslatedText(
                      text: localization.address,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: helpRequest.address ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,
                  ],
                ),
              ),
              SizeBox.sizeHX2,
              if (helpRequest.documents?.isNotEmpty == true)
                Row(
                  children: [
                    Text(
                      localization.supporting_documents,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              SizeBox.sizeHX2,
              if (helpRequest.documents?.isNotEmpty == true)
                ResponisveImageWidget(images: helpRequest.documents ?? []),
              SizeBox.sizeHX6,
            ],
          ),
        ),
      ),
      bottomNavigationBar: helpRequest.status == "closed"
          ? SizedBox()
          : Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.verticalspacing,
              ),
              child: CommonButton(
                isEnable: helpRequest.status == "rejected" ? false : true,
                disabledColor: AppPalettes.greyColor,
                color: helpRequest.status == "rejected"
                    ? AppPalettes.greyColor
                    : null,
                text: isEditable
                    ? localization.edit_details
                    : isFinancialHelp
                    ? localization.contribute
                    : localization.chat,
                onTap: () => RouteManager.pushNamed(
                  isEditable
                      ? Routes.myHelpRequestEditPage
                      : isFinancialHelp
                      ? Routes.contributePage
                      : Routes.chatContributePage,
                  arguments: helpRequest,
                ),
              ),
            ),
    );
  }
}
