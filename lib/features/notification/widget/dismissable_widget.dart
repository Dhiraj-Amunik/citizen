import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart'
    as nm;
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as woh;
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/features/nearest_member/view_model/my_member_message_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/financial_help_messages_view_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart' as complaint;
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:provider/provider.dart';

class NotificationCard extends StatelessWidget {
  final Data notification;

  const NotificationCard({super.key, required this.notification});

  /// Try to enrich Wall of Help chat args from cached chat list (FinancialHelpMessagesViewModel)
  woh.FinancialRequest _buildWallOfHelpArgs(
    BuildContext context,
    String messageId,
  ) {
    try {
      final vm = context.read<FinancialHelpMessagesViewModel>();
      final chat =
          vm.myFinancialHelpChats.firstWhere((c) => c.messageId == messageId);
      final user = chat.relatedUser;
      return woh.FinancialRequest(
        sId: chat.financialHelpRequest,
        messageId: chat.messageId,
        name: user?.userName,
        description: user?.reason,
      );
    } catch (_) {
      // Provider not found or no match; fall back
    }
    return woh.FinancialRequest(messageId: messageId);
  }

  /// Try to enrich Nearest Member chat args from cached chat list (MyMemberMessageViewModel)
  nm.PartyMember _buildNearestMemberArgs(
    BuildContext context,
    String memberId,
    String? userType,
  ) {
    try {
      final vm = context.read<MyMemberMessageViewModel>();
      final chat =
          vm.myChatsList.firstWhere((c) => c.chatWith?.sId == memberId);
      final user = chat.chatWith;
      return nm.PartyMember(
        sId: user?.sId,
        name: user?.name,
        email: user?.email,
        phone: user?.phone,
        avatar: user?.avatar,
        partyMemberDetails: nm.PartyMemberDetails(
          sId: memberId,
          type: chat.chatWithType ?? userType ?? "PartyMember",
        ),
      );
    } catch (_) {
      // Provider not found or no match; fall back
    }

    return nm.PartyMember(
      partyMemberDetails: nm.PartyMemberDetails(
        sId: memberId,
        type: userType ?? "PartyMember",
      ),
    );
  }

  /// Try to enrich Complaint args from cached complaints list (ComplaintsViewModel)
  complaint.Data _buildComplaintArgs(
    BuildContext context,
    String complaintId,
  ) {
    try {
      final vm = context.read<ComplaintsViewModel>();
      final cachedComplaint = vm.complaintsList.firstWhere(
        (c) => c.sId == complaintId || c.threadId == complaintId,
      );
      // Use cached complaint data which has all the details
      return cachedComplaint;
    } catch (_) {
      // Provider not found or no match; fall back
    }
    // Return minimal complaint data with just the ID
    return complaint.Data(sId: complaintId);
  }

  void _handleNavigation(BuildContext context) {
    final module = notification.module?.toLowerCase();
    final moduleId = notification.moduleId;

    if (moduleId == null || moduleId.isEmpty) {
      CommonSnackbar(text: "Unable to open conversation").showToast();
      return;
    }

    if (module == 'wallofhelp') {
      // Navigate to Wall of Help chat using messageId, enrich from cached list when available
      final request = _buildWallOfHelpArgs(context, moduleId);

      RouteManager.pushNamed(
        Routes.chatContributePage,
        arguments: request,
      );
      return;
    }

    if (module == 'nearestpartymember') {
      // Navigate to Nearest Member chat using member id and recipient type, enrich from cached list when available
      final member =
          _buildNearestMemberArgs(context, moduleId, notification.userType);

      RouteManager.pushNamed(
        Routes.chatMemberPage,
        arguments: member,
      );
      return;
    }

    if (module == 'compliant' || module == 'complaint' || module == 'complaints') {
      // Navigate to Complaint thread using complaint id, enrich from cached list when available
      final complaintData = _buildComplaintArgs(context, moduleId);

      RouteManager.pushNamed(
        Routes.threadComplaintPage,
        arguments: complaintData,
      );
      return;
    }
  }

  /// Remove "MLA" from text for appointment notifications
  /// Associates might not be ruling MLA but still part of party and leader
  String _removeMlaFromText(String text) {
    if (text.isEmpty) return text;
    
    // Remove "MLA" in various forms (case-insensitive)
    String cleaned = text
        .replaceAll(RegExp(r'\bMLA\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bM\.L\.A\.\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bM\.L\.A\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bmla\b', caseSensitive: false), '');
    
    // Clean up extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  String _getNotificationMessage() {
    final baseMessage = notification.message ?? 'No description available';
    
    // Check if this is an appointment notification
    final isAppointmentNotification = notification.type?.toLowerCase() == 'appointment';
    
    // Remove "MLA" from appointment notification messages
    final cleanedMessage = isAppointmentNotification 
        ? _removeMlaFromText(baseMessage)
        : baseMessage;
    
    // Check if the base message already contains date/time information
    // This prevents duplication for rescheduled notifications where the backend already includes date/time
    final hasDatePattern = baseMessage.toLowerCase().contains(' on ') || 
                          baseMessage.toLowerCase().contains(' at ') ||
                          RegExp(r'\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[,\s]', caseSensitive: false).hasMatch(baseMessage);
    
    // First, try to get date from appointmentId object (from API response)
    if (isAppointmentNotification && notification.appointmentIdObject != null) {
      final appointment = notification.appointmentIdObject!;
      final date = appointment.date;
      final timeSlot = appointment.timeSlot;
      final rescheduledDate = appointment.rescheduledDate;
      final status = appointment.status?.toLowerCase() ?? '';
      final isApproved = status == 'approved';
      
      // Determine which date to use (rescheduled date takes priority)
      final appointmentDate = (rescheduledDate ?? '').trim().isNotEmpty
          ? rescheduledDate
          : date;
      
      if (appointmentDate != null && appointmentDate.isNotEmpty && !hasDatePattern) {
        try {
          final formattedDate = appointmentDate.toDdMmmYyyy();
          String timeInfo = '';
          
          // Add time slot only if appointment is approved or rescheduled
          // When appointment is approved, show time slot
          if ((isApproved || status == 'rescheduled') && timeSlot != null && timeSlot.trim().isNotEmpty) {
            final formattedTime = timeSlot.to12HourTimeFormat();
            timeInfo = ' at $formattedTime';
          }
          
          // Append date and time to the message only if not already present
          return '$cleanedMessage on $formattedDate$timeInfo';
        } catch (e) {
          // If date parsing fails, fall through to metadata check
        }
      }
    }
    
    // Fallback: Check metadata for date (for appointment approved notifications)
    // Note: For approved appointments, show time slot in metadata fallback
    if (isAppointmentNotification && notification.metadata != null) {
      final metadata = notification.metadata!;
      final date = metadata.date;
      final timeSlot = metadata.timeSlot;
      final rescheduledDate = metadata.rescheduledDate;
      
      // Check if appointment is approved or rescheduled by checking the title or message
      // If appointmentIdObject is null but metadata exists, check notification title/message for "approved" or "rescheduled"
      final isApproved = (notification.title?.toLowerCase().contains('approved') ?? false) ||
                        (notification.message?.toLowerCase().contains('approved') ?? false);
      final isRescheduled = (notification.title?.toLowerCase().contains('rescheduled') ?? false) ||
                           (notification.message?.toLowerCase().contains('rescheduled') ?? false) ||
                           ((rescheduledDate ?? '').trim().isNotEmpty);
      
      // Determine which date to use (rescheduled date takes priority)
      final appointmentDate = (rescheduledDate ?? '').trim().isNotEmpty
          ? rescheduledDate
          : date;
      
      if (appointmentDate != null && appointmentDate.isNotEmpty && !hasDatePattern) {
        try {
          final formattedDate = appointmentDate.toDdMmmYyyy();
          String timeInfo = '';
          
          // Add time slot only if appointment is approved or rescheduled
          // When appointment is approved, show time slot
          if ((isApproved || isRescheduled) && timeSlot != null && timeSlot.trim().isNotEmpty) {
            final formattedTime = timeSlot.to12HourTimeFormat();
            timeInfo = ' at $formattedTime';
          }
          
          // Append date and time to the message only if not already present
          return '$cleanedMessage on $formattedDate$timeInfo';
        } catch (e) {
          // If date parsing fails, return cleaned message
          return cleanedMessage;
        }
      }
    }
    
    // Return cleaned message for appointment notifications, original for others
    return cleanedMessage;
  }
  
  String _getNotificationTitle() {
    final title = notification.title ?? 'Notification';
    
    // Check if this is an appointment notification
    final isAppointmentNotification = notification.type?.toLowerCase() == 'appointment';
    
    // Remove "MLA" from appointment notification titles
    return isAppointmentNotification 
        ? _removeMlaFromText(title)
        : title;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final notificationMessage = _getNotificationMessage();
    
    // Check if this is a chat notification (wallofhelp or nearestpartymember)
    // Chat notifications contain user names that should NOT be translated
    final module = notification.module?.toLowerCase();
    final type = notification.type?.toLowerCase();
    final isChatNotification = module == 'wallofhelp' || module == 'nearestpartymember';
    
    // Explicitly check for notify representative and complaint notifications
    // These should always be translated (force translation)
    // Also check message content and title as fallback for better detection
    final messageLower = notificationMessage.toLowerCase();
    final titleLower = notification.title?.toLowerCase() ?? '';
    final isNotifyRepresentative = module == 'notifyrepresentative' || 
                                   module == 'notify_representative' || 
                                   module == 'notify' ||
                                   type == 'notifyrepresentative' ||
                                   type == 'notify_representative' ||
                                   type == 'notify' ||
                                   messageLower.contains('notify representative') ||
                                   messageLower.contains('notifyrepresentative') ||
                                   messageLower.contains('सूचित प्रतिनिधि') || // Hindi: "notify representative"
                                   titleLower.contains('notify') ||
                                   titleLower.contains('सूचित प्रतिनिधि'); // Hindi: "notify representative"
    final isComplaint = module == 'compliant' || 
                       module == 'complaint' || 
                       module == 'complaints' ||
                       type == 'complaint' ||
                       type == 'complaints';
    
    // Force translation for notify representative and complaint notifications ALWAYS
    // For other notifications, force translate if NOT a chat notification
    // This ensures notify representative descriptions are ALWAYS translated
    final shouldForceTranslate = isNotifyRepresentative || isComplaint || !isChatNotification;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleNavigation(context),
      child: Container(
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
                    text: _getNotificationTitle(),
                    style: textTheme.titleMedium,
                    forceTranslation: true,
                  ),
                  ReadMoreWidget(
                    text: notificationMessage,
                    maxLines: 2,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppPalettes.lightTextColor,
                      fontSize: 14.spMax,
                    ),
                    // Force translation for notify representative and complaint notifications
                    // Don't translate chat notifications - they contain user names in registered language
                    // Other notification types (appointments, etc.) should also be translated
                    forceTranslation: shouldForceTranslate,
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
      ),
    );
  }
}
