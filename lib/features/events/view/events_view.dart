import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
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
    final localization = context.localizations;
    return Scaffold(
      appBar: commonAppBar(title: localization.events),
      body: Column(
        children: [
          DefaultTabBar(
            controller: tabController,
            tabLabels: const ["Ongoing", "Upcoming", "Past"],
          ),
          Expanded(
            child: Consumer<EventsViewModel>(
              builder: (context, value, _) {
                if (value.isLoading) {
                  return Center(child: CustomAnimatedLoading());
                }
                return TabBarView(
                  controller: tabController,
                  children: [
                    buildWidget(
                      value.ongoingEventList,
                      () => value.getEvents(EventFilter.ongoing),
                      EventFilter.ongoing,
                    ),
                    buildWidget(
                      value.upcomingEventList,
                      () => value.getEvents(EventFilter.upcoming),
                      EventFilter.upcoming,
                    ),
                    buildWidget(
                      value.pastEventList,
                      () => value.getEvents(EventFilter.past),
                      EventFilter.past,
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
  }

  Widget buildWidget(
    List<model.Events> data,
    Future<void> Function() onRefresh,
    EventFilter type,
  ) {
    if (data.isEmpty) {
      return EventsHelpers.eventPlaceholder(type: type, onRefresh: onRefresh);
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
