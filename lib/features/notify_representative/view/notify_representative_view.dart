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
            provider.searchController.clear();
            provider.onSearchChanged(tabController.index);
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
                Text(
                  localization.your_notified_events,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ).horizontalPadding(Dimens.horizontalspacing),
                Consumer<ShowSearchNotifyProvider>(
                  builder: (contextP, search, _) {
                    if (!search.showSearchWidget) {
                      return Column(
                        children: [
                          SizeBox.sizeHX3,
                          DefaultTabBar(
                            controller: tabController,
                            tabLabels: const ["Recent", "Past"],
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
                            child: value.recentNotifyLists.isEmpty
                                ? NotifyReprHelper.emptyPlaceholder(
                                    type: "Recent",
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
                            child: value.pastNotifyLists.isEmpty
                                ? NotifyReprHelper.emptyPlaceholder(
                                    type: "Past",
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
}
