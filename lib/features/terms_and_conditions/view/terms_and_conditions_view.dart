import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

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
                        'Terms and Conditions',
                        style: AppStyles.titleLarge,
                      ),
                    ),
                  ),
                  // Optionally add a SizedBox or another widget to maintain symmetrical layout
                ],
              ),
              Text('Last Updated in August 2025', style: AppStyles.titleSmall),
              Text(
                'Welcome to Citizen Connect. By downloading, registering, or using our mobile application (“App”), you agree to the following Terms & Conditions. Please read them carefully before using the app.',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text('Eligibility', style: AppStyles.titleSmall),
              Text(
                'The app is available to citizens who register using a valid mobile number and OTP.You must be at least 18 years of age or have parental consent to use the app.',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text('Account Registration', style: AppStyles.titleSmall),
              Text(
                'Users must provide accurate details such as name, phone number, date of birth, gender, and Aadhaar number during registration.You are responsible for keeping your login credentials (OTP, phone number) confidential.',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text('Use of the App', style: AppStyles.titleSmall),
              Text(
                '''The app is intended for:
•  Submitting complaints to local authorities.
•  Tracking the status of complaints.
•  Viewing and registering for community events.
•  Donating towards verified causes.
•  Accessing temple information, darshan booking, and other civic services.
•  You agree not to misuse the app by:
•  Submitting false or misleading complaints.
•  Uploading offensive, harmful, or illegal content.
•  Using another person’s identity or details.''',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text(' Complaints & Content Upload', style: AppStyles.titleSmall),
              Text(
                'Complaints must be genuine and related to civic issues. You may upload photos, but they must not include objectionable content.The app reserves the right to remove or reject complaints that violate these terms.',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),

              Text(' Donations', style: AppStyles.titleSmall),
              Text(
                'Donations made through the app are voluntary and non-refundable. Secure payment gateways are used, and receipts are generated instantly. The app is not responsible for issues arising from third-party payment providers.',
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.blackColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
