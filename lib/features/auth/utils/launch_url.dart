import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchURL extends StatelessWidget {
  const LaunchURL({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return RichText(
      textAlign: TextAlign.center,
      maxLines: 2,
      text: TextSpan(
        style: context.textTheme.labelMedium,
        children: [
          TextSpan(text: "${localization.by_continuing_u_agree_to_our} "),

          TextSpan(
            style: context.textTheme.labelMedium,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchURL("https://www.clokam.com/terms"),
            text: localization.terms_of_services,
          ),
          TextSpan(text: " ${localization.and} "),

          TextSpan(
            style: context.textTheme.labelMedium,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchURL("https://www.clokam.com/privacy"),
            text: localization.privacy_policy,
          ),
        ],
      ),
    );
  }

  _launchURL(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
