import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';
import 'package:inldsevak/core/widgets/responisve_image_widget.dart';
import 'package:inldsevak/features/common_fields/view_model/mla_view_model.dart';
import 'package:provider/provider.dart';

class AppointmentDetailsView extends StatelessWidget {
  final Appointments appointment;

  const AppointmentDetailsView({super.key, required this.appointment});
  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final documents = appointment.documents ?? [];

    return Scaffold(
      appBar: commonAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
          child: Column(
            children: [
              SizedBox(
                width: 0.8.screenWidth,
                child: TranslatedText(
                  text: appointment.purpose ?? "",
            
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              SizeBox.sizeHX,
              ReadMoreWidget(maxLines: 4, text: appointment.reason ?? ""),
              SizeBox.sizeHX2,

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX4,
                  vertical: Dimens.paddingX4,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX4,
                  backgroundColor: AppPalettes.liteGreenColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TranslatedText(
                      text: "Associate Name",
                  
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Consumer<MlaViewModel>(
                      builder: (context, mlaViewModel, _) {
                        // First try to get name from populated MLA object
                        String? mlaName = appointment.mlaObject?.user?.name;
                        
                        // If not available, look up from MLA list using the MLA ID
                        if (mlaName == null || mlaName.isEmpty) {
                          final mlaId = appointment.mla is String 
                              ? appointment.mla as String?
                              : appointment.mlaObject?.sId;
                          if (mlaId != null && mlaViewModel.mlaLists.isNotEmpty) {
                            final matchedMla = mlaViewModel.mlaLists.where(
                              (mla) => mla.sId == mlaId,
                            ).firstOrNull;
                            mlaName = matchedMla?.user?.name;
                          }
                        }
                        
                        return TranslatedText(
                          text: mlaName ?? "N/A",
                    
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppPalettes.lightTextColor,
                          ),
                        );
                      },
                    ),
                    SizeBox.sizeHX1,
                    TranslatedText(
                      text: "Purpose",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ReadMoreWidget(
                      maxLines: 3,
                      text: appointment.purpose ?? "",
                      style: TextStyle(
                        fontSize: textTheme.bodyMedium?.fontSize ?? 14,
                        color: AppPalettes.lightTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    TranslatedText(
                      text: "Scheduled Date",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: () {
                        final hasRescheduledDate = (appointment.rescheduledDate ?? '').trim().isNotEmpty;
                        // If rescheduled, show only date (no timeSlot) for scheduled date
                        if (hasRescheduledDate) {
                          return appointment.date?.toDdMmmYyyy() ?? "";
                        } else {
                          // If not rescheduled, show date + timeSlot
                          return appointment.timeSlot != null && appointment.timeSlot!.isNotEmpty
                              ? "${appointment.date?.toDdMmmYyyy() ?? ""} at ${appointment.timeSlot!.to12HourTimeFormat()}"
                              : appointment.date?.toDdMmmYyyy() ?? "";
                        }
                      }(),
             
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    if ((appointment.rescheduledDate ?? '').trim().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizeBox.sizeHX1,
                          TranslatedText(
                            text: "Rescheduled Date",
                    
                            style: textTheme.bodySmall?.copyWith(
                              color: AppPalettes.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TranslatedText(
                            text: appointment.timeSlot != null && appointment.timeSlot!.isNotEmpty
                                ? "${appointment.rescheduledDate?.toDdMmmYyyy() ?? ""} at ${appointment.timeSlot!.to12HourTimeFormat()}"
                                : appointment.rescheduledDate?.toDdMmmYyyy() ?? "",
                     
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppPalettes.lightTextColor,
                            ),
                          ),
                        ],
                      ),
                    SizeBox.sizeHX1,
                    SizeBox.sizeHX1,
                    TranslatedText(
                      text: "Name",
                
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: appointment.name ?? "",
              
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,

                    TranslatedText(
                      text: "Contact No",
              
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: appointment.phone ?? "",
                
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,
                  ],
                ),
              ),
              SizeBox.sizeHX2,
              if (documents.isNotEmpty)
                Row(
                  children: [
                    TranslatedText(
                      text: "Images",
                  
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppPalettes.blackColor,
                      ),
                    ),
                  ],
                ),
              SizeBox.sizeHX2,
              if (documents.isNotEmpty)
                ResponisveImageWidget(images: documents),
              SizeBox.sizeHX6,
            ],
          ),
        ),
      ),
    );
  }
}
