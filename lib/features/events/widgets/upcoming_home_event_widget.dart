import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/events/model/events_model.dart' as model;
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/features/events/model/request_details_event_model.dart';

class UpcomingEventWidget extends StatelessWidget {
  final model.Events event;
  const UpcomingEventWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return GestureDetector(
      onTap: () => RouteManager.pushNamed(
        Routes.eventDetailsPage,
        arguments: RequestEventDetailsModel(eventId: event.sId!),
      ),
      child: Container(
        width: 200.height(),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX2,
          vertical: Dimens.paddingX2,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          border: Border.all(color: AppPalettes.primaryColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Dimens.gapX2,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(Dimens.radiusX2),
                ),
                child: CommonHelpers.getCacheNetworkImage(event.poster),
              ),
            ),
            Column(
              spacing: Dimens.gapX,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title ?? "Unknown title",
                  style: textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  event.location ?? "Unknown Location",
                  style: textTheme.labelMedium?.copyWith(
                    color: AppPalettes.lightTextColor,
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Wrap(
                        runSpacing: Dimens.gapX,
                        spacing: Dimens.gapX2,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: Dimens.gapX1,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: Dimens.scaleX1B,
                              ),
                              Text(
                                event.createdAt?.toDdMmmYyyy() ?? "0-00-0000",
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppPalettes.lightTextColor,
                                ),
                              ),
                            ],
                          ),
                      
                          Row(
                            spacing: Dimens.gapX1,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: Dimens.scaleX1B),
                              Text(
                                event.createdAt?.to12HourTime() ?? "00:00  ",
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppPalettes.lightTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
