import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/events/model/events_model.dart' as model;
import 'package:inldsevak/core/extensions/context_extension.dart';

class EventWidget extends StatelessWidget {
  final model.Events event;
  final VoidCallback? onTap;
  const EventWidget({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX3,
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX6,
          border: Border.all(color: AppPalettes.buttonColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.radiusX4),
                  child: event.poster != null && event.poster!.isNotEmpty
                      // ?
                      //CommonHelpers.getCacheNetworkImage(event.poster)
                      // : Container(
                      // width: double.infinity,
                      // height: 130.h,
                      // color: AppPalettes.greyColor.withOpacityExt(0.3),
                      // child: Icon(Icons.event, size: 40.sp), // ), ),
                      ? Image.asset(
                          'assets/banners/banner_1.png',
                          width: double.infinity,
                          height: 130.h,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 130.h,
                          color: AppPalettes.greyColor.withOpacityExt(0.3),
                          child: Icon(Icons.event, size: 40.sp),
                        ),
                ),
                Positioned(
                  right: 12.w,
                  bottom: -12.h,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.paddingX2,
                          vertical: Dimens.paddingX1,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xffDBEAFE),
                          borderRadius: BorderRadius.circular(Dimens.radius100),
                        ),
                        child: Text(
                          event.createdAt?.toDdMmmYyyy() ?? "0-00-0000",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppPalettes.blackColor.withOpacityExt(0.6),
                          ),
                        ),
                      ),
                      SizedBox(width: Dimens.paddingX2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.paddingX2,
                          vertical: Dimens.paddingX1,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xffC9FACC),

                          borderRadius: BorderRadius.circular(Dimens.radius100),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14.h,
                              color: AppPalettes.blackColor.withOpacityExt(0.6),
                            ),
                            SizedBox(width: Dimens.paddingX1),
                            Text(
                              event.createdAt?.to12HourTime() ?? "00:00",
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.blackColor.withOpacityExt(
                                  0.6,
                                ),
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
            SizeBox.sizeHX4,
            Text(event.title ?? "Unknown Title", style: textTheme.bodyMedium),
            Text(
              event.location ?? "Unknown Location",
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
    // return GestureDetector(
    //   onTap: () => RouteManager.pushNamed(
    //     Routes.eventDetailsPage,
    //     arguments: RequestEventDetailsModel(eventId: event.sId!),
    //   ),
    //   child: Row(
    //     spacing: Dimens.gapX2,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       SizedBox(
    //         height: 60,
    //         width: 60,
    //         child: ClipRRect(
    //           borderRadius: BorderRadius.all(Radius.circular(Dimens.radiusX2)),
    //           child: CommonHelpers.getCacheNetworkImage(event.poster),
    //         ),
    //       ),
    //       Column(
    //         spacing: Dimens.gapX,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(event.title ?? "Unknown title", style: textTheme.bodySmall),
    //           Row(
    //             spacing: Dimens.gapX1,
    //             children: [
    //               Icon(Icons.location_on_outlined, size: Dimens.scaleX2),
    //               Text(
    //                 event.location ?? "Unknown Location",
    //                 style: textTheme.labelMedium,
    //               ),
    //             ],
    //           ),
    //           Row(
    //             spacing: Dimens.gapX1,
    //             children: [
    //               Icon(Icons.calendar_month_outlined, size: Dimens.scaleX2),
    //               Text(
    //                 event.createdAt?.toDdMmmYyyy() ?? "0-00-0000",
    //                 style: textTheme.labelMedium,
    //               ),
    //               SizeBox.sizeWX1,
    //               Icon(Icons.access_time, size: Dimens.scaleX2),
    //               Text(
    //                 event.createdAt?.to12HourTime() ?? "00:00  ",
    //                 style: textTheme.labelMedium,
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
