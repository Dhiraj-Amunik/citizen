import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_styles.dart';

class NotifyReprHelper {
  static Widget emptyPlaceholder({
    required String type,
  }) {
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
          Text(
            "No $type notified events found",
            style: AppStyles.titleMedium,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}