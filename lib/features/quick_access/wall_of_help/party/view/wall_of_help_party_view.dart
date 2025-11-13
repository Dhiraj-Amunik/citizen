import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/custom_container_widget.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/party_help_card.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';

class WallOfHelpPartyView extends StatelessWidget {
  const WallOfHelpPartyView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WallOfHelpViewModel>();
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return RefreshIndicator(
      onRefresh: () async {
        provider.onRefresh();
      },
      child: Scaffold(
        appBar: commonAppBar(
          center: true,
          title: localization.wall_of_help,
          action: [
            SizeBox.sizeWX2,
            CommonButton(
              text: localization.my_requests,
              fullWidth: false,
              padding: EdgeInsets.symmetric(
                vertical: Dimens.paddingX1,
                horizontal: Dimens.paddingX3,
              ),
              height: 28,
              radius: Dimens.radiusX3,
              onTap: () => RouteManager.pushNamed(Routes.myRequestsPage),
            ),
          ],
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          controller: provider.scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.widgetSpacing,
              children: [
                CustomContainerWidget(
                  route: Routes.requestWallOfHelpPage,
                  heading: "A Family That Cares",
                  desciption:
                      "Beyond politics, we build trust and support. With the Wall of Help, you’re never alone assistance is always near.",
                  buttonText: "+ ${localization.request_help}",
                ),
                Text(localization.helping_hands_gains_love,style: textTheme.headlineSmall,),
                  Row(
                spacing: Dimens.gapX2,
                children: [
                  Expanded(
                    child: FormTextFormField(
                      hintText: localization.search,
                      suffixIcon: AppImages.searchIcon,
                      controller: provider.searchController,
                      borderColor: AppPalettes.primaryColor,
                      fillColor: AppPalettes.whiteColor,
                      onChanged: provider.onSearchChanged,
                    ),
                  ),
                  CommonHelpers.buildIcons(
                    path: AppImages.filterIcon,
                    color: AppPalettes.primaryColor,
                    iconSize: Dimens.scaleX2B,
                    padding: Dimens.paddingX3,
                    radius: Dimens.radiusX3,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return DraggableSheetWidget(
                            showClose: true,
                            size: 0.5,
                            bottomChild: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Dimens.paddingX4,
                                horizontal: Dimens.paddingX4,
                              ),
                              child: Row(
                                spacing: Dimens.gapX4,
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      text: localization.clear,
                                      height: 45,
                                      color: Colors.white,
                                      borderColor: AppPalettes.greenColor,
                                      textColor: AppPalettes.greenColor,
                                      onTap: () {
                                        RouteManager.pop();
                                        provider.searchController.clear();
                                        provider.statusKey = null;
                                        provider.dateKey = null;
                                        provider.onRefresh();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: CommonButton(
                                      height: 45,
                                      text: localization.apply,
                                      onTap: () {
                                        RouteManager.pop();
                                        provider.onRefresh();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      localization.filters,
                                      style: context.textTheme.headlineSmall,
                                    ),
                                  ],
                                ),
                                SizeBox.sizeHX2,

                                Consumer<WallOfHelpViewModel>(
                                  builder: (_, _, _) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: Dimens.gapX2,
                                      children: [
                                        FormCommonChild(
                                          heading: localization.select_status,
                                          child: Wrap(
                                            spacing: Dimens.gapX2,
                                            runSpacing: Dimens.gapX2,
                                            alignment: WrapAlignment.start,
                                            children: [
                                              ...List.generate(
                                                provider.statusItems.length,
                                                (index) {
                                                  final bool isSelected =
                                                      provider.statusKey ==
                                                      provider
                                                          .statusItems[index];
                                                  return CommonButton(
                                                    fullWidth: false,
                                                    borderColor: AppPalettes
                                                        .primaryColor,
                                                    textColor: isSelected
                                                        ? AppPalettes.whiteColor
                                                        : AppPalettes
                                                              .lightTextColor,
                                                    color: isSelected
                                                        ? AppPalettes
                                                              .primaryColor
                                                        : AppPalettes
                                                              .whiteColor,
                                                    radius: Dimens.radiusX3,

                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              Dimens.paddingX4,
                                                          vertical:
                                                              Dimens.paddingX1B,
                                                        ),
                                                    text: provider
                                                        .statusItems[index].capitalize(),
                                                    height: 33.height(),
                                                    onTap: () =>
                                                        provider.setStatus(
                                                          provider
                                                              .statusItems[index],
                                                        ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        FormCommonChild(
                                          heading: localization.date,
                                          child: Wrap(
                                            spacing: Dimens.gapX2,
                                            runSpacing: Dimens.gapX2,
                                            alignment: WrapAlignment.start,
                                            children: [
                                              ...List.generate(
                                                provider.dateItems.length,
                                                (index) {
                                                  final bool isSelected =
                                                      provider.dateKey ==
                                                      provider.dateItems[index];
                                                  return CommonButton(
                                                    fullWidth: false,
                                                    borderColor: AppPalettes
                                                        .primaryColor,
                                                    textColor: isSelected
                                                        ? AppPalettes.whiteColor
                                                        : AppPalettes
                                                              .lightTextColor,
                                                    color: isSelected
                                                        ? AppPalettes
                                                              .primaryColor
                                                        : AppPalettes
                                                              .whiteColor,
                                                    radius: Dimens.radiusX3,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              Dimens.paddingX4,
                                                          vertical:
                                                              Dimens.paddingX1B,
                                                        ),
                                                    text: provider
                                                        .dateItems[index],
                                                    height: 33.height(),
                                                    onTap: () =>
                                                        provider.setDate(
                                                          provider
                                                              .dateItems[index],
                                                        ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ).symmetricPadding(horizontal: Dimens.horizontalspacing),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            
                Consumer<WallOfHelpViewModel>(
                  builder: (context, value, _) {
                    if (value.isLoading) {
                      return Column(
                        children: [
                          SizedBox(height: 0.2.screenHeight),
                          Center(child: CustomAnimatedLoading()),
                          SizeBox.sizeHX2,
                        ],
                      );
                    }
                    if (value.wallOFHelpLists.isEmpty) {
                      return WallOfHelpHelpers.emptyHelper(
                        text: "No requests found",
                        onRefresh: () => value.getWallOfHelpList(),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: value.wallOFHelpLists.length,
                      itemBuilder: (context, index) {
                        return Column(
                          spacing: Dimens.gapX4,
                          children: [
                            PartyHelpCard(
                              helpRequest: value.wallOFHelpLists[index],
                              
                            ),
                            if (value.isScrollLoading &&
                                value.wallOFHelpLists.last ==
                                    value.wallOFHelpLists[index])
                              CustomAnimatedLoading(),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizeBox.widgetSpacing,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
