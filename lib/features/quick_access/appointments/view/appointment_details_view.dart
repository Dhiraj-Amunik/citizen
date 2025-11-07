import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';
import 'package:inldsevak/core/widgets/responisve_image_widget.dart';

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
                child: Text(
                  appointment.purpose ?? "",
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
                    Text(
                      "Associate Name",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    Text(
                      "Hon. Abhay Singh Chautala",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    Text(
                      "Purpose",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      appointment.purpose ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    Text(
                      "Scheduled Date",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    Text(
                      appointment.date?.toDdMmmYyyy() ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    SizeBox.sizeHX1,
                    Text(
                      "Name",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    Text(
                      appointment.name ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizeBox.sizeHX1,

                    Text(
                      "Contact No",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    Text(
                      appointment.phone ?? "",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
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
                    Text(
                      "Images",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
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
