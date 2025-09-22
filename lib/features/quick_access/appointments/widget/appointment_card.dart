import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointments appointment;
  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        border: BoxBorder.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        spacing: Dimens.gapX,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              spacing: Dimens.gapX3,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    appointment.purpose?.capitalize() ?? "Unknow subject",
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.paddingX3,
                      vertical: Dimens.paddingX,
                    ),
                    decoration: boxDecorationRoundedWithShadow(
                      Dimens.radius100,
                      backgroundColor: AppPalettes.greenColor.withOpacityExt(
                        0.2,
                      ),
                    ),
                    child: Text(
                      appointment.date?.toRelativeTime() ?? "",
                      style: textTheme.labelMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 50.height()),
            child: Text(
              appointment.reason ?? "Unknown Reason",
              style: textTheme.labelMedium?.copyWith(
                color: AppPalettes.lightTextColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
