import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_slidable_container.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class NotificationDateGroup extends StatelessWidget {
  final String date;
  final List<Data> notifications;
  final Function(Data) onDismiss;

  const NotificationDateGroup({
    super.key,
    required this.date,
    required this.notifications,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: REdgeInsets.only(bottom: Dimens.paddingX3),
          child: Text(date.toDdMmmYyyy()),
        ),
        ...notifications.map(
          (notification) => Padding(
            padding: REdgeInsets.only(bottom: Dimens.paddingX3),
            child: DismissibleNotificationCard(
              key: ValueKey("notification.id"),
              notification: notification,
              onDismissed: () => onDismiss(notification),
            ),
          ),
        ),
      ],
    );
  }
}

class DismissibleNotificationCard extends StatelessWidget {
  final Data notification;
  final VoidCallback onDismissed;

  const DismissibleNotificationCard({
    super.key,
    required this.notification,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = 80.h;

    return CommonSlidableContainer(
      extendRatio: 0.27,
      isEnable: false,
      actions: [
        10.horizontalSpace,
        // ActionButton.getButtons(
        //   onTap: onDismissed,
        //   size: Size(buttonSize, buttonSize),
        //   svgIcon: AppImages.close,
        //   color: AppPalette.red,
        //   borderRadius: 14.r,
        // ),
      ],
      child: NotificationCard(notification: notification),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Data notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(Dimens.paddingX4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppPalettes.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacityExt(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: Dimens.gapX3,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(AppImages.logo, scale: Dimens.scaleX1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX,
              children: [
                Text(
                  notification.title ?? 'Notification',
                  style: textTheme.titleMedium,
                ),
                ReadMoreText(
                  notification.message ?? 'No description available',
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  textAlign: TextAlign.start,
                  trimCollapsedText: ' Read‎‎‎more',
                  trimExpandedText: ' Show‎‎‎less',
                  moreStyle: textTheme.bodyMedium,
                  lessStyle: textTheme.bodyMedium,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppPalettes.lightTextColor,
                    fontSize: 14.spMax,
                  ),
                ),
                Padding(
                  padding: REdgeInsets.only(right: Dimens.paddingX1,top: Dimens.paddingX1),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      notification.createdAt?.toRelativeTime() ?? "",
                      style: textTheme.labelMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
