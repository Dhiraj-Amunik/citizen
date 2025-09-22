import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/utils/url_launcher.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_expanded_widget.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/profile_tabs/view_model/help_and_support_view_model.dart';
import 'package:provider/provider.dart';

class HelpAndSupportView extends StatefulWidget {
  const HelpAndSupportView({super.key});

  @override
  State<HelpAndSupportView> createState() => _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends State<HelpAndSupportView> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<HelpAndSupportViewModel>();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        provider.clearSearch();
      },
      child: Scaffold(
        appBar: commonAppBar(
          title: localization.help_and_support,
          center: true,
          elevation: Dimens.elevation,
        ),
        body: SingleChildScrollView(
          child:
              Column(
                spacing: Dimens.widgetSpacing,
                children: [
                  FormTextFormField(
                    controller: provider.searchController,
                    prefixIcon: AppImages.searchIcon,
                    hintText: localization.search_for_help,
                  ),
                  Container(
                    decoration: boxDecorationRoundedWithShadow(
                      Dimens.radiusX2,
                      backgroundColor: AppPalettes.whiteColor,
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localization.frequently_asked_questions,
                          style: textTheme.bodyMedium,
                        ).horizontalPadding(Dimens.paddingX4),
                        const Divider(color: AppPalettes.dividerColor),
                        Consumer<HelpAndSupportViewModel>(
                          builder: (context, value, _) {
                            if (value.filteredQuestionList.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(Dimens.paddingX4),
                                  child: Text(
                                    value.searchController.text.isEmpty
                                        ? 'No FAQs available'
                                        : 'No results found for "${value.searchController.text}"',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppPalettes.lightTextColor,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: value.filteredQuestionList.length,
                              itemBuilder: (context, index) {
                                final data = value.filteredQuestionList[index];

                                return CommonExpandedWidget(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimens.paddingX4,
                                  ),
                                  elevation: 0,
                                  iconColor: AppPalettes.blackColor,
                                  title: data.question,
                                  textStyle: textTheme.bodySmall,
                                  radius: Dimens.radiusX2,
                                  alignment: Alignment.centerLeft,
                                  childrenPadding: Dimens.paddingX4,
                                  childrenBottomPadding: Dimens.padding,
                                  splashColor: AppPalettes.transparentColor,
                                  children: [
                                    Text(
                                      "• ${data.answer}",
                                      style: textTheme.labelLarge?.copyWith(
                                        color: AppPalettes.lightTextColor,
                                      ),
                                    ),
                                  ],
                                );
                              },

                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    color: AppPalettes.dividerColor,
                                  ),
                            );
                          },
                        ),
                      ],
                    ).verticalPadding(Dimens.paddingX4),
                  ),

                  Container(
                    decoration: boxDecorationRoundedWithShadow(Dimens.radiusX4,spreadRadius: 2,blurRadius: 2),
                    child: CommonExpandedWidget(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.paddingX4,
                        vertical: Dimens.paddingX1,
                      ),
                      
                      iconColor: AppPalettes.blackColor,
                      title: localization.contact_information,
                      subtTitle: localization.get_in_touch_with_our_support_team,
                      textStyle: textTheme.bodySmall,
                      subTitleTextStyle: textTheme.labelMedium,
                      radius: Dimens.radiusX4,
                      alignment: Alignment.centerLeft,
                      splashColor: AppPalettes.transparentColor,
                      children: [
                        const Divider(color: AppPalettes.dividerColor, height: 1),
                        SizeBox.sizeHX4,
                        GestureDetector(
                          onTap: () => UrlLauncher().launchURl(),
                          onLongPress: () =>
                              UrlLauncher().launchTel("+91 8765397865"),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Dimens.gapX4,
                            children: [
                              CommonHelpers.buildIcons(
                                color: AppPalettes.primaryColor.withOpacityExt(
                                  0.2,
                                ),
                                path: AppImages.phoneIcon,
                                iconColor: AppPalettes.primaryColor,
                                iconSize: Dimens.scaleX2,
                                padding: Dimens.paddingX2B,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: Dimens.gapX,
                                children: [
                                  Text(
                                    localization.phone,
                                    style: textTheme.bodySmall,
                                  ),
                                  Text(
                                    "+91 8765397865",
                                    style: textTheme.bodySmall,
                                  ),
                                  Text(
                                    localization.support_24_7,
                                    style: textTheme.labelMedium?.copyWith(
                                      color: AppPalettes.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).symmetricPadding(horizontal: Dimens.paddingX4),
                        ),
                        SizeBox.sizeHX4,
                        GestureDetector(
                          onTap: () => UrlLauncher().launchURl(),
                          onLongPress: () => UrlLauncher().launchEmail(
                            "support@citizen.in",
                            subject: "Enter-your-complaint-issue",
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Dimens.gapX4,
                            children: [
                              Container(
                                child: CommonHelpers.buildIcons(
                                  color: AppPalettes.primaryColor.withOpacityExt(
                                    0.2,
                                  ),
                                  path: AppImages.emailIcon,
                                  iconColor: AppPalettes.primaryColor,
                                  iconSize: Dimens.scaleX1B,
                                  padding: Dimens.paddingX2,
                                ),
                              ),
                              Column(
                                spacing: Dimens.gapX,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.email,
                                    style: textTheme.bodySmall,
                                  ),
                                  Text(
                                    "support@citizen.in",
                                    style: textTheme.bodySmall,
                                  ),
                                  Text(
                                    localization.response_within_24_hours,
                                    style: textTheme.labelMedium?.copyWith(
                                      color: AppPalettes.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).symmetricPadding(horizontal: Dimens.paddingX4),
                        ),
                        SizeBox.sizeHX4,
                      ],
                    ),
                  ),

                  SizeBox.sizeHX7,
                ],
              ).symmetricPadding(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.verticalspacing,
              ),
        ),
      ),
    );
  }
}
