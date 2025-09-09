import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/events/view_model/events_view_model.dart';
import 'package:inldsevak/features/events/widgets/event_widget.dart';
import 'package:inldsevak/features/events/widgets/events_helpers.dart';
import 'package:provider/provider.dart';

class UpComingHomeEventsWidget extends StatelessWidget {
  const UpComingHomeEventsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsViewModel>();
    final textTheme = context.textTheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX4,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX2,
        spreadRadius: 2,
        blurRadius: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Dimens.gapX2,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upcoming Events",
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPalettes.primaryColor,
                  height: 1,
                ),
              ),
              GestureDetector(
                onTap: () => RouteManager.pushNamed(Routes.eventsPage),
                child: Icon(Icons.arrow_forward_ios_rounded),
              ),
            ],
          ),
          //
          if (provider.isLoading)
            SizedBox(
              height: 60,
              child: CommonHelpers.shimmer(radius: Dimens.radiusX2),
            ),
          //
          if (provider.homeEventList.isEmpty && !provider.isLoading)
            EventsHelpers.upComingPlaceholder(onRefresh: () async {}),
          //
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              return EventWidget(event: provider.homeEventList[index]);
            },
            separatorBuilder: (_, _) => EventsHelpers.eventDivider(),
            itemCount: provider.homeEventList.length,
          ),
        ],
      ),
    );
  }
}
