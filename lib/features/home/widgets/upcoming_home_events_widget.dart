import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/events/view_model/events_view_model.dart';
import 'package:inldsevak/features/events/widgets/events_helpers.dart';
import 'package:inldsevak/features/events/widgets/upcoming_home_event_widget.dart';
import 'package:provider/provider.dart';

class UpComingHomeEventsWidget extends StatelessWidget {
  const UpComingHomeEventsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.gapX2B,
      children: [
        GestureDetector(
          onTap: () => RouteManager.pushNamed(Routes.eventsPage),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization.upcoming_events,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppPalettes.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                localization.see_all,
                style: textTheme.titleMedium?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
            ],
          ).horizontalPadding(Dimens.horizontalspacing),
        ),
        //

        //
        Consumer<EventsViewModel>(
          builder: (context, value, _) {
            if (value.isLoading) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.horizontalspacing,
                ),
                height: 160.height(),
                child: CommonHelpers.shimmer(radius: Dimens.radiusX2),
              );
            }

            if (value.homeEventList.isEmpty) {
              return EventsHelpers.upComingPlaceholder(onRefresh: () async {});
            }
            return SizedBox(
              height: 160.height(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.horizontalspacing,
                ),
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  return UpcomingEventWidget(event: value.homeEventList[index]);
                },
                separatorBuilder: (_, _) => SizeBox.sizeWX3,
                itemCount: value.homeEventList.length,
              ),
            );
          },
        ),
      ],
    );
  }
}
