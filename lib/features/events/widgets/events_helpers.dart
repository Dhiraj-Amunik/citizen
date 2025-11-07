import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/features/events/model/request_event_model.dart';

class EventsHelpers {
  static Widget eventPlaceholder({
    required EventFilter type,
    required Future<void> Function() onRefresh,
    double? height,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: (height ?? 0.2).screenHeight),
            CommonHelpers.buildIcons(
              path: AppImages.placeholderEmpty,
              iconSize: 0.5.screenWidth,
            ),
            Text(
              "No ${type.name} events found",
              style: AppStyles.titleMedium,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget upComingPlaceholder({
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
            CommonHelpers.buildIcons(
              path: AppImages.placeholderEmpty,
              iconSize: 0.25.screenWidth,
            ),
            Text(
              "No ${EventFilter.upcoming.name} events found",
              style: AppStyles.titleSmall,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
