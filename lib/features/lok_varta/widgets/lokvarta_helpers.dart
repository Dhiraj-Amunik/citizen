import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';

class LokvartaHelpers {
  static Widget lokVartaPlaceholder({
    required LokVartaFilter type,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(
          parent: NeverScrollableScrollPhysics(),
        ),
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
              "No ${type.name.endsWith("s") ? type.name : '${type.name}s'} found",
              style: AppStyles.titleMedium,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget lokVartaDivider() {
    return Padding(
      padding: EdgeInsets.only(right: 00.width()),
      child: Divider(
        height: Dimens.paddingX4,
        color: AppPalettes.primaryColor.withOpacityExt(0.5),
      ),
    );
  }
}
