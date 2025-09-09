import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(title: 'Privacy Policy'),
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
              'This Privacy Policy explains how Citizen Connect (“App”, “we”, “our”, or “us”) collects, uses, and protects your personal information. By using the app, you agree to the practices described in this policy.',
              style: context.textTheme.bodySmall,
            ),

            Text('Information We Collect', style: context.textTheme.titleSmall),
            Text(
              '''When you use Citizen Connect, we may collect the following information:
•  Personal Details: Name, mobile number, email, Aadhaar number, date of birth, gender (provided during registration).
•  Location Data: To pinpoint the exact location of complaints or services requested.
•  Complaint Data: Titles, descriptions, photos, and attachments you upload.
•  Donation Data: Transaction details when you make donations (note: we do not store card/UPI details).
•  Device Information: Device type, operating system, and app usage data to improve services.
''',
              style: context.textTheme.bodySmall,
            ),

            Text(
              'How We Use Your Information',
              style: context.textTheme.titleSmall,
            ),
            Text('''Your data is used for the following purposes:
•  To verify your identity and create a secure account.
•  To submit and process complaints with the relevant authorities.
•  To update you on the status of your complaints.
•  To enable darshan bookings, temple services, and event participation.
•  To process donations securely and generate receipts.
•  To provide customer support and resolve technical issues.
•  To improve app features, security, and user experience. and app usage data to improve services.
''', style: context.textTheme.bodySmall),

            Text('Data Security', style: context.textTheme.titleSmall),
            Text(
              'All sensitive information, including Aadhaar and payment data, is encrypted. Access to your data is restricted to authorized officials and administrators. We regularly review our security measures to protect against unauthorized access, loss, or misuse.',
              style: context.textTheme.bodySmall,
            ),
            Text('User Rights', style: context.textTheme.titleSmall),
            Text('''As a user of Citizen Connect, you have the right to:
•  Access: Request a copy of your personal data.
•  Correction: Update incorrect or outdated information.
•  Deletion: Request deletion of your account and data permanently.
•  Withdraw Consent: Stop using the app and revoke data permissions at any time.
''', style: context.textTheme.bodySmall),
            SizeBox.sizeHX1,
          ],
        ).symmetricPadding(horizontal: Dimens.horizontalspacing),
      ),
    );
  }
}
