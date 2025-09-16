import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class AuthUtils {
  static PreferredSizeWidget appbar({String? title, bool canPop = false}) {
    return AppBar(
      scrolledUnderElevation: 2,
      elevation: 0,
      automaticallyImplyLeading: canPop,
      toolbarHeight: 60.height(),
      backgroundColor: AppPalettes.whiteColor,
      shadowColor: AppPalettes.shadowColor,
      foregroundColor: AppPalettes.whiteColor,
      surfaceTintColor: AppPalettes.whiteColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppPalettes.whiteColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: Dimens.horizontalspacing),
        child: CommonHelpers.buildIcons(path: AppImages.partySign),
      ),
      leadingWidth: 0.2.screenWidth,
      centerTitle: true,
      titleSpacing: 0,
      title: (title != null)
          ? Text(
              title,
              style: AppStyles.headlineSmall,
            ).horizontalPadding(Dimens.paddingX3)
          : null,
    );
  }
}
