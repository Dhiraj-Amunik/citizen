import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';


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
                TranslatedText(
                  text: notification.title ?? 'Notification',
                  style: textTheme.titleMedium,
                ),
                ReadMoreWidget(
                  text: notification.message ?? 'No description available',
                  maxLines: 2,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppPalettes.lightTextColor,
                    fontSize: 14.spMax,
                  ),
                ),
                Padding(
                  padding: REdgeInsets.only(
                    right: Dimens.paddingX1,
                    top: Dimens.paddingX1,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TranslatedText(
                      text: 
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
