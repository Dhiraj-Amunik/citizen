import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(title: 'Terms and Conditions'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimens.widgetSpacing,
          children: [
            SizeBox.sizeHX1,
            Text(
              'Last Updated in August 2025',
              style: context.textTheme.titleSmall,
            ),
            Text(
              'Welcome to Citizen Connect. By downloading, registering, or using our mobile application (“App”), you agree to the following Terms & Conditions. Please read them carefully before using the app.',
              style: context.textTheme.bodySmall,
            ),

            Text('Eligibility', style: context.textTheme.titleSmall),
            Text(
              'The app is available to citizens who register using a valid mobile number and OTP.You must be at least 18 years of age or have parental consent to use the app.',
              style: AppStyles.bodySmall,
            ),

            Text('Account Registration', style: context.textTheme.titleSmall),
            Text(
              'Users must provide accurate details such as name, phone number, date of birth, gender, and Aadhaar number during registration.You are responsible for keeping your login credentials (OTP, phone number) confidential.',
              style: context.textTheme.bodySmall,
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
              style: context.textTheme.bodySmall,
            ),

            Text(
              ' Complaints & Content Upload',
              style: context.textTheme.titleSmall,
            ),
            Text(
              'Complaints must be genuine and related to civic issues. You may upload photos, but they must not include objectionable content.The app reserves the right to remove or reject complaints that violate these terms.',
              style: AppStyles.bodySmall,
            ),

            Text(' Donations', style: context.textTheme.titleSmall),
            Text(
              'Donations made through the app are voluntary and non-refundable. Secure payment gateways are used, and receipts are generated instantly. The app is not responsible for issues arising from third-party payment providers.',
              style: context.textTheme.bodySmall,
            ),
            Text(
              ' Privacy & Data Protection',
              style: context.textTheme.titleSmall,
            ),
            Text(
              'We value your privacy. Personal details such as Aadhaar, phone, and email are encrypted and shared only with authorized officials. Please read our Privacy Policy for full details on how your data is managed',
              style: AppStyles.bodySmall,
            ),
            SizeBox.sizeHX1,
          ],
        ).symmetricPadding(horizontal: Dimens.horizontalspacing),
      ),
    );
  }
}
