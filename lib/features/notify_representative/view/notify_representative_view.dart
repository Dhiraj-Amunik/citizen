import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/animated_search_widget.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/custom_container_widget.dart';
import 'package:inldsevak/core/widgets/default_tabbar.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/view_model/notify_representative_view_model.dart';
import 'package:inldsevak/features/notify_representative/widgets/notify_container.dart';
import 'package:inldsevak/features/notify_representative/widgets/notify_repr_helper.dart';
import 'package:provider/provider.dart';

class NotifyRepresentativeView extends StatefulWidget {
  const NotifyRepresentativeView({super.key});

  @override
  State<NotifyRepresentativeView> createState() =>
      _NotifyRepresentativeViewState();
}

class _NotifyRepresentativeViewState extends State<NotifyRepresentativeView>
    with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<NotifyRepresentativeViewModel>();
    return ChangeNotifierProvider(
      create: (contextP) => ShowSearchNotifyProvider(),
      builder: (contextP, _) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              provider.searchController.clear();
              provider.clearFilters();
              provider.onSearchChanged(tabController.index);
            }
          },
          child: Scaffold(
            appBar: commonAppBar(
              title: localization.notify_representative,
              action: [
                Consumer<ShowSearchNotifyProvider>(
                  builder: (contextP, search, _) {
                    return !search.showSearchWidget
                        ? CommonHelpers.buildIcons(
                            color: AppPalettes.liteGreenColor,
                            padding: Dimens.paddingX2,
                            path: AppImages.searchIcon,
                            onTap: () => search.showSearchWidget = true,
                          )
                        : SizedBox();
                  },
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<ShowSearchNotifyProvider>(
                  builder: (contextP, search, _) {
                    return search.showSearchWidget
                        ? AnimatedSearchBar(
                            controller: provider.searchController,
                            onChanged: (text) =>
                                provider.onSearchChanged(tabController.index),
                            onClear: () {
                              provider.searchController.clear();
                              provider.onSearchChanged(tabController.index);
                              search.showSearchWidget = false;
                            },
                          )
                        : AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            child: CustomContainerWidget(
                              route: Routes.createNotifyRepresentativePage,
                              heading: localization.notify_mla,
                              desciption: localization.notify_description,
                              buttonText: "+ ${localization.notify}",
                            ).horizontalPadding(Dimens.horizontalspacing),
                          );
                  },
                ),
                SizeBox.widgetSpacing,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.your_notified_events,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CommonHelpers.buildIcons(
                      color: AppPalettes.primaryColor,
                      padding: Dimens.paddingX2,
                      radius: Dimens.radiusX3,
                      path: AppImages.filterIcon,

                      onTap: () => _showFilterSheet(context, provider),
                    ),
                  ],
                ).horizontalPadding(Dimens.horizontalspacing),
                Consumer<ShowSearchNotifyProvider>(
                  builder: (contextP, search, _) {
                    if (!search.showSearchWidget) {
                      return Column(
                        children: [
                          SizeBox.sizeHX3,
                          DefaultTabBar(
                            controller: tabController,
                            tabLabels: [localization.recent, localization.past],
                          ),
                        ],
                      );
                    }
                    return SizeBox.size;
                  },
                ),
                SizeBox.widgetSpacing,
                Expanded(
                  child: Consumer<NotifyRepresentativeViewModel>(
                    builder: (context, value, _) {
                      if (value.isLoading) {
                        return Center(child: CustomAnimatedLoading());
                      }
                      return TabBarView(
                        controller: tabController,
                        children: [
                          RefreshIndicator(
                            onRefresh: () async {
                              value.onRecentRefresh();
                            },
                            color: AppPalettes.primaryColor,
                            child: value.recentNotifyLists.isEmpty
                                ? NotifyReprHelper.emptyPlaceholder(
                                    type: "Recent",
                                    context: context,
                                  )
                                : ListView.separated(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    controller: value.recentScrollController,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.paddingX2,
                                    ),
                                    shrinkWrap: true,
                                    itemBuilder: (_, index) {
                                      return NotifyContainer(
                                        model: value.recentNotifyLists[index],
                                        onDelete: () => value.deleteNotify(
                                          value.recentNotifyLists[index],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (_, _) => SizeBox.sizeHX2,
                                    itemCount: value.recentNotifyLists.length,
                                  ),
                          ),
                          RefreshIndicator(
                            onRefresh: () async {
                              value.onPastRefresh();
                            },
                            color: AppPalettes.primaryColor,
                            child: value.pastNotifyLists.isEmpty
                                ? NotifyReprHelper.emptyPlaceholder(
                                    type: "Past",
                                    context: context,
                                  )
                                : ListView.separated(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    controller: value.pastScrollController,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.paddingX2,
                                    ),
                                    shrinkWrap: true,
                                    itemBuilder: (_, index) {
                                      return NotifyContainer(
                                        model: value.pastNotifyLists[index],
                                      );
                                    },
                                    separatorBuilder: (_, _) => SizeBox.sizeHX2,
                                    itemCount: value.pastNotifyLists.length,
                                  ),
                          ),
                        ],
                      ).symmetricPadding(
                        horizontal: Dimens.paddingX3,
                        vertical: Dimens.paddingX2,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(
    BuildContext context,
    NotifyRepresentativeViewModel provider,
  ) {
    // Fetch fresh filters data every time the sheet opens
    provider.getNotifyFilters();
    final localization = context.localizations;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableSheetWidget(
        size: 0.7,
        bottomChild: Padding(
          padding: EdgeInsets.all(Dimens.paddingX3),
          child: Row(
            spacing: Dimens.gapX2,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    provider.clearFilters();
                    RouteManager.pop();
                  },
                  child: TranslatedText(
                    text: localization.clear,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: AppPalettes.primaryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CommonButton(
                  height: 45,
                  child: TranslatedText(
                    text: localization.apply,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: AppPalettes.whiteColor,
                    ),
                  ),
                  onTap: () {
                    RouteManager.pop();
                  },
                ),
              ),
            ],
          ),
        ),
        child: Consumer<NotifyRepresentativeViewModel>(
          builder: (context, value, _) {
            // Show loading while filters are being fetched
            if (value.isFiltersLoading || value.filtersData == null) {
              return Padding(
                padding: EdgeInsets.all(Dimens.paddingX3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppPalettes.primaryColor,
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(Dimens.paddingX3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TranslatedText(
                        text: localization.filters,
                        style: context.textTheme.headlineSmall,
                      ),
                    ],
                  ).verticalPadding(Dimens.paddingX2),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimens.gapX3,
                    children: [
                      // MLA Filter
                      if (value.filtersData?.mlas != null &&
                          value.filtersData!.mlas!.isNotEmpty)
                        FormCommonDropDown<MlaFilter>(
                          heading: 'Associate',
                          hintText: localization.select_mla,
                          initialData: value.selectedMla,
                          items: value.filtersData?.mlas,
                          listItemBuilder: (context, mla, _, __) {
                            return TranslatedText(
                              text: mla.user?.name ?? '',
                              style: context.textTheme.bodySmall,
                              disableTranslation: true,
                            );
                          },
                          headerBuilder: (context, mla, _) {
                            return TranslatedText(
                              text: mla.user?.name ?? '',
                              style: context.textTheme.bodySmall,
                              disableTranslation: true,
                            );
                          },
                          onChanged: (selectedValue) {
                            value.setMla(selectedValue);
                          },
                        ),

                      // District Filter
                      if (value.filtersData?.districts != null &&
                          value.filtersData!.districts!.isNotEmpty)
                        FormCommonDropDown<String>(
                          heading: localization.district,
                          hintText: 'Select District',
                          initialData: value.selectedDistrict,
                          items: value.filtersData?.districts,
                          listItemBuilder: (context, district, _, __) {
                            return TranslatedText(
                              text: district,
                              style: context.textTheme.bodySmall,
                            );
                          },
                          headerBuilder: (context, district, _) {
                            return TranslatedText(
                              text: district,
                              style: context.textTheme.bodySmall,
                            );
                          },
                          onChanged: (selectedValue) {
                            value.setDistrict(selectedValue);
                          },
                        ),

                      // Tehsil Filter
                      if (value.filtersData?.mandals != null &&
                          value.filtersData!.mandals!.isNotEmpty)
                        FormCommonDropDown<String>(
                          heading: 'Tehsil',
                          hintText:
                              'Select Tehsil', // TODO: Add tehsil localization key
                          initialData: value.selectedMandal,
                          items: value.filtersData?.mandals,
                          listItemBuilder: (context, mandal, _, __) {
                            return TranslatedText(
                              text: mandal,
                              style: context.textTheme.bodySmall,
                            );
                          },
                          headerBuilder: (context, mandal, _) {
                            return TranslatedText(
                              text: mandal,
                              style: context.textTheme.bodySmall,
                            );
                          },
                          onChanged: (selectedValue) {
                            value.setMandal(selectedValue);
                          },
                        ),

                      // City/Town Filter
                      if (value.filtersData?.villages != null &&
                          value.filtersData!.villages!.isNotEmpty)
                        FormCommonDropDown<String>(
                          heading: localization.city_village,
                          hintText: 'Select City/Town',
                          initialData: value.selectedVillage,
                          items: value.filtersData?.villages,
                          listItemBuilder: (context, village, _, __) {
                            return TranslatedText(
                              text: village,
                              style: context.textTheme.bodySmall,
                            );
                          },
                          headerBuilder: (context, village, _) {
                            return TranslatedText(
                              text: village,
                              style: context.textTheme.bodySmall,
                            );
                          },
                          onChanged: (selectedValue) {
                            value.setVillage(selectedValue);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
