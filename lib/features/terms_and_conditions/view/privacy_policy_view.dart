import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/terms_and_conditions/widgets/custom_event_container_widget.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimens.widgetSpacing,
            children: [
              SizedBox(height: 60.h),
              Row(
                children: [
                  SvgPicture.asset(AppImages.leadingBackIcon),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Privacy Policy',
                        style: AppStyles.titleLarge,
                      ),
                    ),
                  ),
                  // Optionally add a SizedBox or another widget to maintain symmetrical layout
                ],
              ),
              Text('Last Updated in August 2025', style: AppStyles.titleSmall),
              Text(
                'This Privacy Policy explains how Citizen Connect (“App”, “we”, “our”, or “us”) collects, uses, and protects your personal information. By using the app, you agree to the practices described in this policy.',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text('Information We Collect', style: AppStyles.titleSmall),
              Text(
                '''When you use Citizen Connect, we may collect the following information:
•  Personal Details: Name, mobile number, email, Aadhaar number, date of birth, gender (provided during registration).
•  Location Data: To pinpoint the exact location of complaints or services requested.
•  Complaint Data: Titles, descriptions, photos, and attachments you upload.
•  Donation Data: Transaction details when you make donations (note: we do not store card/UPI details).
•  Device Information: Device type, operating system, and app usage data to improve services.
''',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text('How We Use Your Information', style: AppStyles.titleSmall),
              Text(
                '''Your data is used for the following purposes:
•  To verify your identity and create a secure account.
•  To submit and process complaints with the relevant authorities.
•  To update you on the status of your complaints.
•  To enable darshan bookings, temple services, and event participation.
•  To process donations securely and generate receipts.
•  To provide customer support and resolve technical issues.
•  To improve app features, security, and user experience. and app usage data to improve services.
''',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text('Data Security', style: AppStyles.titleSmall),
              Text(
                'All sensitive information, including Aadhaar and payment data, is encrypted. Access to your data is restricted to authorized officials and administrators. We regularly review our security measures to protect against unauthorized access, loss, or misuse.',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),
              SizeBox.sizeHX10,

              CustomEventContainerWidget(
                event: EventModel(
                  imageUrl: "assets/banners/banner_1.png",
                  date: '15 Aug, 2025',
                  time: '11:43 PM',
                  title: 'Ganesha 2025',
                  location: 'Tiburon',
                ),
                onTap: () {
                  print('Event tapped!');
                },
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
