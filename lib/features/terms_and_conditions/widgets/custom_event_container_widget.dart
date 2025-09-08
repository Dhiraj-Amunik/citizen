import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class EventModel {
  final String imageUrl;
  final String date;
  final String time;
  final String title;
  final String location;
  EventModel({
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
  });
}

class CustomEventContainerWidget extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  const CustomEventContainerWidget({
    super.key,
    required this.event,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(Dimens.radiusX6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusX2),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX3,
            vertical: Dimens.paddingX3,
          ),
          decoration: boxDecorationRoundedWithShadow(
            Dimens.radiusX6,
            border: Border.all(color: AppPalettes.buttonColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image at the top
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.radiusX4),
                    child: Image.asset(
                      event.imageUrl,
                      width: double.infinity,
                      height: 130.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: -15,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.paddingX2,
                            vertical: Dimens.paddingX1,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xffDBEAFE),
                            borderRadius: BorderRadius.circular(
                              Dimens.radius100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                event.date,
                                style: AppStyles.labelMedium.copyWith(
                                  color: AppPalettes.blackColor.withOpacity(
                                    0.6,
                                  ),
                                ),
                              ),
                            ],
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
                            borderRadius: BorderRadius.circular(
                              Dimens.radius100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.sp,
                                color: AppPalettes.blackColor.withOpacity(0.6),
                              ),
                              SizedBox(width: Dimens.paddingX1),
                              Text(
                                event.time,
                                style: AppStyles.labelMedium.copyWith(
                                  color: AppPalettes.blackColor.withOpacity(
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
              SizeBox.sizeHX4, // Title and Location
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppStyles.bodyMedium),
                  Text(event.location, style: context.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
