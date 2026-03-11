import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/notification/models/notify_popup_model.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';

class NotificationPopupDialog extends StatelessWidget {
  final NotifyPopupItem item;
  final VoidCallback onClose;

  const NotificationPopupDialog({
    super.key,
    required this.item,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppPalettes.transparentColor,
      insetPadding: EdgeInsets.symmetric(horizontal: Dimens.paddingX4),
      elevation: 0,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: context.screenHeight * 0.8),
            decoration: BoxDecoration(
              color: AppPalettes.whiteColor,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Space for Circle Avatar
                SizedBox(height: 50.h),

                // "You got a new notification" Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX4),
                  child: TranslatedText(
                    text:
                        (item.type?.toLowerCase() == 'custom' ||
                            item.module?.toLowerCase() == 'custom')
                        ? "New Notification!"
                        : "You got an official announcement!",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppPalettes.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: Dimens.gapX2),

                // Scrollable Content Section (Image + Title + Message)
                Flexible(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 4.w,
                    radius: Radius.circular(Dimens.radiusX2),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.paddingX4,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Image Section (Now scrollable)
                          if (item.image != null && item.image!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: Dimens.gapX2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimens.radiusX2,
                                ),
                                child: Image.network(
                                  item.image!,
                                  width: double.infinity,
                                  fit: BoxFit.fitWidth,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ),

                          // Actual Notification Title
                          TranslatedText(
                            text: (item.title != null && item.title!.isNotEmpty)
                                ? item.title!
                                : "Official Update",
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppPalettes.blackColor,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: Dimens.gapX2),

                          // Message
                          TranslatedText(
                            text:
                                (item.message != null &&
                                    item.message!.isNotEmpty)
                                ? item.message!
                                : "Please check the official announcements section for details.",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppPalettes.lightTextColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Dimens.gapX2),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer Section (Fixed)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: Dimens.gapX2),
                      // Close Button
                      CommonButton(
                        onTap: onClose,
                        text: "Close", // TODO: Localization
                        color: AppPalettes.primaryColor,
                        textColor: AppPalettes.whiteColor,
                        radius: 30.r,
                        height: 45.h,
                        width: 150.w,
                      ),
                      SizedBox(height: Dimens.gapX4),
                      // Hint Text for History
                      Padding(
                        padding: EdgeInsets.only(bottom: Dimens.gapX2),
                        child: TranslatedText(
                          text:
                              "*Check the Official Announcements in the Profile section to view all announcements.*",
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppPalettes.lightTextColor,
                            fontStyle: FontStyle.italic,
                            fontSize: 10.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Circle Avatar with Notification Icon
          Positioned(
            top: -35.h,
            child: CircleAvatar(
              radius: 40.r,
              backgroundColor: AppPalettes.whiteColor,
              child: Container(
                padding: EdgeInsets.all(Dimens.paddingX),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalettes.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CommonHelpers.buildIcons(
                  path: AppImages.notificationIcon,
                  color: AppPalettes.primaryColor.withOpacityExt(0.1),
                  iconColor: AppPalettes.primaryColor,
                  padding: Dimens.paddingX2,
                  iconSize: Dimens.scaleX4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
