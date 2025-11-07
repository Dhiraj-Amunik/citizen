import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_styles.dart';

class WallOfHelpHelpers {
  static Widget emptyHelper({
    required String text,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 0.1.screenHeight),
            CommonHelpers.buildIcons(
              path: AppImages.placeholderEmpty,
              iconSize: 0.5.screenWidth,
            ),
            Text(
              text,
              style: AppStyles.titleMedium,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
