import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointments appointment;
  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX2,
      ).copyWith(right: Dimens.paddingX2),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        border: BoxBorder.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: Dimens.gapX3,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appointment.status != null)
                CommonHelpers.buildStatus(
                  appointment.status?.capitalize() ?? "",
                  textColor: AppPalettes.blackColor,
                  statusColor: appointment.isDeleted == true
                      ? AppPalettes.redColor
                      : appointment.status == 'approved'
                      ? AppPalettes.greenColor
                      : AppPalettes.yellowColor,
                ),
            ],
          ),
          Text(
            appointment.purpose?.capitalize() ?? "Unknow subject",
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).onlyPadding(right: Dimens.paddingX2),
          SizeBox.sizeHX,
          Text(
            "${appointment.status?.toLowerCase() == 'rescheduled' ? localization.rescheduled_date : localization.scheduled_date} : ${appointment.date?.toDdMmmYyyy()}",
            style: textTheme.labelMedium?.copyWith(
              color: AppPalettes.lightTextColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          SizeBox.sizeHX,
          Text(
            appointment.reason ?? "Unknown Reason",
            style: textTheme.labelMedium?.copyWith(
              color: AppPalettes.lightTextColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          SizeBox.sizeHX2,
        ],
      ),
    );
  }
}
