import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

class NotifyReprHelper {
  static Widget emptyPlaceholder({
    required String type,
    required BuildContext context,
  }) {
    final localization = context.localizations;
    final text = type.toLowerCase() == 'recent'
        ? localization.no_recent_notified_events_found
        : localization.no_past_notified_events_found;
    
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: ( 0.1).screenHeight),
          CommonHelpers.buildIcons(
            path: AppImages.placeholderEmpty,
            iconSize: 0.5.screenWidth,
          ),
          TranslatedText(
            text: text,
            style: AppStyles.titleMedium,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}