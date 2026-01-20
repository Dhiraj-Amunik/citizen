import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';

class AppointmentCard extends StatelessWidget {
  final Appointments appointment;
  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    final scheduledDate = appointment.date?.toDdMmmYyyy() ?? '--';
    final timeSlot = appointment.timeSlot?.trim() ?? '';
    final appointmentStatus = appointment.status?.toLowerCase() ?? '';
    
    // Simple logic based on status:
    // - pending: don't show time
    // - approved: show timeslot (only if timeSlot is not empty)
    // - rescheduled: show timeslot in rescheduled date (only if timeSlot is not empty)
    // - cancelled: don't show timeslot
    final isPending = appointmentStatus == 'pending';
    final isApproved = appointmentStatus == 'approved';
    final isRescheduled = appointmentStatus == 'rescheduled';
    final isCancelled = appointmentStatus == 'cancelled';
    
    // Check if timeSlot exists and is not empty
    final hasTimeSlot = timeSlot.isNotEmpty;
    
    // Determine if we should show time in scheduled date based on status
    // For rescheduled status: don't show time in scheduled date (show it in rescheduled date instead)
    // For approved status: show time in scheduled date
    final shouldShowTimeInScheduledDate = isApproved && 
                                           !isPending && 
                                           !isCancelled && 
                                           !isRescheduled &&  // Don't show time in scheduled date when rescheduled
                                           hasTimeSlot;
    
    // Format time slot to 12-hour format (needed for both scheduled and rescheduled dates)
    final timeSlot12Hour = hasTimeSlot 
        ? timeSlot.to12HourTimeFormat() 
        : '';
    
    final hasRescheduledDate = (appointment.rescheduledDate ?? '')
        .toString()
        .trim()
        .isNotEmpty;
    
    final rescheduledDateFormatted = hasRescheduledDate
        ? appointment.rescheduledDate?.toDdMmmYyyy()
        : null;
    
    // Build scheduled date string
    // For rescheduled status: show only date (no time)
    // For approved status: show date with time if available
    final scheduledDateTime = shouldShowTimeInScheduledDate && hasTimeSlot && timeSlot12Hour.isNotEmpty
        ? "$scheduledDate at $timeSlot12Hour"
        : scheduledDate;
    
    // Build rescheduled date string
    // For rescheduled status: show date with time (if timeSlot is available)
    // For other statuses: show date with time if available
    String? rescheduledDateTime;
    if (rescheduledDateFormatted != null) {
      // For rescheduled status, show date with time if timeSlot is available
      if (isRescheduled) {
        if (hasTimeSlot && timeSlot12Hour.isNotEmpty) {
          rescheduledDateTime = "$rescheduledDateFormatted at $timeSlot12Hour";
        } else {
          // If no time slot, show just the date (fallback)
          rescheduledDateTime = rescheduledDateFormatted;
        }
      } else {
        // For other statuses, show date with time if available
        // Use shouldShowTimeInScheduledDate logic for consistency
        if (shouldShowTimeInScheduledDate && hasTimeSlot && timeSlot12Hour.isNotEmpty) {
          rescheduledDateTime = "$rescheduledDateFormatted at $timeSlot12Hour";
        } else {
          rescheduledDateTime = rescheduledDateFormatted;
        }
      }
    }
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
                  spacing: Dimens.gapX1,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TranslatedText(
                            text: appointment.purpose?.capitalize() ??
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
                                : appointment.status == 'rescheduled'
                                ? AppPalettes.liteOrangeColor
                                : AppPalettes.yellowColor,
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Dimens.gapX1B,
                      children: [
                        Text(
                          "${localization.scheduled_date} : $scheduledDateTime",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppPalettes.lightTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Only show rescheduled date if status is actually "rescheduled"
                        if (isRescheduled && rescheduledDateFormatted != null)
                          Text(
                            "${localization.rescheduled_date} : $rescheduledDateTime",
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
    final double radius = Dimens.scaleX3;

    // Check if imageUrl is null or empty to prevent invalid URL errors
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return _InitialsAvatar(
        text: fallbackText,
        radius: radius,
        textTheme: textTheme,
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

/// Widget that displays initials from text, translating it first if needed
class _InitialsAvatar extends StatefulWidget {
  final String text;
  final double radius;
  final TextTheme textTheme;

  const _InitialsAvatar({
    required this.text,
    required this.radius,
    required this.textTheme,
  });

  @override
  State<_InitialsAvatar> createState() => _InitialsAvatarState();
}

class _InitialsAvatarState extends State<_InitialsAvatar> {
  String _initials = "A";
  StreamSubscription<dynamic>? _languageSubscription;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _updateInitials();
    // Listen to language changes for instant retranslation
    _languageSubscription = GeneralStream.instance.language.listen((_) {
      if (mounted) {
        _updateInitials();
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_InitialsAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _updateInitials();
    }
  }

  Future<void> _updateInitials() async {
    if (widget.text.isEmpty) {
      setState(() {
        _initials = "A";
        _isTranslating = false;
      });
      return;
    }

    // Check if translation is needed
    final needsTranslation = TranslationHelper.needsTranslation(widget.text);
    
    if (!needsTranslation) {
      // No translation needed, extract initials directly
      setState(() {
        _initials = CommonHelpers.getInitials(widget.text);
        _isTranslating = false;
      });
      return;
    }

    // Translation is needed
    setState(() {
      _isTranslating = true;
    });

    try {
      final translated = await TranslationHelper.translateText(widget.text);
      if (mounted) {
        setState(() {
          _initials = CommonHelpers.getInitials(translated);
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initials = CommonHelpers.getInitials(widget.text);
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: AppPalettes.primaryColor.withOpacityExt(0.1),
      child: _isTranslating
          ? SizedBox(
              width: widget.radius * 0.6,
              height: widget.radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppPalettes.primaryColor,
                ),
              ),
            )
          : Text(
              _initials,
              style: widget.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPalettes.primaryColor,
              ),
            ),
    );
  }
}
