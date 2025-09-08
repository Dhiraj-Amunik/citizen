import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/events/model/events_model.dart' as model;
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/features/events/model/request_details_event_model.dart';

class EventWidget extends StatelessWidget {
  final model.Events event;
  const EventWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return GestureDetector(
      onTap: () => RouteManager.pushNamed(
        Routes.eventDetailsPage,
        arguments: RequestEventDetailsModel(eventId: event.sId!),
      ),
      child: Row(
        spacing: Dimens.gapX2,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(Dimens.radiusX2)),
              child: CommonHelpers.getCacheNetworkImage(event.poster),
            ),
          ),
          Column(
            spacing: Dimens.gapX,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title ?? "Unknown title", style: textTheme.bodySmall),
              Row(
                spacing: Dimens.gapX1,
                children: [
                  Icon(Icons.location_on_outlined, size: Dimens.scaleX2),
                  Text(
                    event.location ?? "Unknown Location",
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
              Row(
                spacing: Dimens.gapX1,
                children: [
                  Icon(Icons.calendar_month_outlined, size: Dimens.scaleX2),
                  Text(
                    event.createdAt?.toDdMmmYyyy() ?? "0-00-0000",
                    style: textTheme.labelMedium,
                  ),
                  SizeBox.sizeWX1,
                  Icon(Icons.access_time, size: Dimens.scaleX2),
                  Text(
                    event.createdAt?.to12HourTime() ?? "00:00  ",
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
