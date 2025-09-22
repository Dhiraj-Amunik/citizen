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
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX3,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          border: Border.all(color: AppPalettes.primaryColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Dimens.gapX,
          children: [
            Stack(
              fit: StackFit.passthrough,
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: Dimens.paddingX2),
                  height: 130.height(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(Dimens.radiusX2),
                    ),
                    child: CommonHelpers.getCacheNetworkImage(event.poster),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: Dimens.paddingX3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: Dimens.gapX2,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.paddingX2,
                          vertical: Dimens.paddingX,
                        ),
                        decoration: boxDecorationRoundedWithShadow(
                          Dimens.radius100,
                          backgroundColor: AppPalettes.liteBlueColor,
                        ),
                        child: Text(
                          event.createdAt?.toDdMmmYyyy() ?? "0-00-0000",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppPalettes.lightTextColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.paddingX2,
                          vertical: Dimens.paddingX,
                        ),
                        decoration: boxDecorationRoundedWithShadow(
                          Dimens.radius100,
                          backgroundColor: AppPalettes.liteGreenColor,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: Dimens.scaleX1B,
                            ),

                            Text(
                              event.createdAt?.to12HourTime() ?? "00:00  ",
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.lightTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  style: textTheme.bodySmall?.copyWith(
                    color: AppPalettes.lightTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
