import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointments appointment;
  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    final scheduledDate = appointment.date?.toDdMmmYyyy() ?? '--';
    final rescheduledDate = (appointment.rescheduledDate ?? '')
        .toString()
        .trim()
        .isEmpty
        ? null
        : appointment.rescheduledDate?.toDdMmmYyyy();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileAvatar(textTheme),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimens.gapX,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            appointment.purpose?.capitalize() ??
                                "Unknow subject",
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).onlyPadding(right: Dimens.paddingX2),
                        ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Dimens.gapX1B,
                      children: [
                        Text(
                          "${localization.scheduled_date} : $scheduledDate",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppPalettes.lightTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (rescheduledDate != null)
                          Text(
                            "${localization.rescheduled_date} : $rescheduledDate",
                            style: textTheme.labelMedium?.copyWith(
                              color: AppPalettes.lightTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    ReadMoreWidget(
                      text: appointment.reason ?? "Unknown Reason",
                      maxLines: 2,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(TextTheme textTheme) {
    final imageUrl = _resolveProfileImage(appointment);
    final fallbackText = appointment.purpose?.trim().isNotEmpty == true
        ? appointment.purpose!.trim()
        : appointment.name ?? "";
    final initials = fallbackText.isNotEmpty
        ? CommonHelpers.getInitials(fallbackText)
        : "A";
    final double radius = Dimens.scaleX2;

    if (imageUrl == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppPalettes.primaryColor.withOpacityExt(0.1),
        child: Text(
          initials,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppPalettes.primaryColor,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(imageUrl),
      onBackgroundImageError: (_, __) {},
    );
  }

  String? _resolveProfileImage(Appointments appointment) {
    final primary = appointment.profileImage;
    String? candidate = primary;

    if (candidate == null || candidate.trim().isEmpty) {
      final docs = appointment.documents;
      if (docs != null && docs.isNotEmpty) {
        candidate = docs.first;
      }
    }

    if (candidate == null || candidate.trim().isEmpty) {
      return null;
    }

    final trimmed = candidate.trim();
    if (trimmed.startsWith('http')) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      return "${URLs.baseURL}$trimmed";
    }

    return "${URLs.baseURL}/$trimmed";
  }
}
