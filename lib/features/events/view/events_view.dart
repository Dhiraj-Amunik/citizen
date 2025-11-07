import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/animated_search_widget.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/default_tabbar.dart';
import 'package:inldsevak/features/events/model/events_model.dart' as model;
import 'package:inldsevak/features/events/model/request_event_model.dart';

import 'package:inldsevak/features/events/view_model/events_view_model.dart';
import 'package:inldsevak/features/events/widgets/event_widget.dart';
import 'package:inldsevak/features/events/widgets/events_helpers.dart';
import 'package:provider/provider.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EventsViewModel>();
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (contextP) => ShowSearchEventProvider(
        clear: () {
          provider.searchController.clear();
          provider.onSearchChanged(tabController.index);
        },
      ),
      builder: (contextP, _) {
        return Scaffold(
          appBar: commonAppBar(
            title: localization.events,
            action: [
              Consumer<ShowSearchEventProvider>(
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
            children: [
              Consumer<ShowSearchEventProvider>(
                builder: (contextP, search, _) {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    child: search.showSearchWidget
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
                        : DefaultTabBar(
                            controller: tabController,
                            tabLabels: const ["Ongoing", "Upcoming", "Past"],
                          ),
                  );
                },
              ),
              SizeBox.sizeHX2,

              Expanded(
                child: Consumer<EventsViewModel>(
                  builder: (context, value, _) {
                    if (value.isLoading|| value.isEventLoading) {
                      return Center(child: CustomAnimatedLoading());
                    }
                    return TabBarView(
                      controller: tabController,
                      children: [
                        EventsBuildWidget(
                          data: value.ongoingEventList,
                          onRefresh: () => value.getEvents(EventFilter.ongoing),
                          type: EventFilter.ongoing,
                        ),

                        EventsBuildWidget(
                          data: value.upcomingEventList,
                          onRefresh: () =>
                              value.getEvents(EventFilter.upcoming),
                          type: EventFilter.upcoming,
                        ),

                        EventsBuildWidget(
                          data: value.pastEventList,
                          onRefresh: () => value.getEvents(EventFilter.past),
                          type: EventFilter.past,
                        ),
                      ],
                    ).symmetricPadding(
                      horizontal: Dimens.paddingX2B,
                      vertical: Dimens.paddingX2,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EventsBuildWidget extends StatelessWidget {
  final List<model.Events> data;
  final Future<void> Function() onRefresh;
  final EventFilter type;
  final double? height;
  const EventsBuildWidget({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.type,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return EventsHelpers.eventPlaceholder(
        type: type,
        onRefresh: onRefresh,
        height: height,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX2),

        shrinkWrap: true,
        itemBuilder: (_, index) {
          return EventWidget(event: data[index]);
        },
        separatorBuilder: (_, _) => SizeBox.widgetSpacing,
        itemCount: data.length,
      ),
    );
  }
}
