import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class AuthUtils {
  static PreferredSizeWidget appbar({String? title, bool canPop = false}) {
    return AppBar(
    scrolledUnderElevation: 0,
      automaticallyImplyLeading: canPop,
      toolbarHeight: 60,
      backgroundColor: AppPalettes.whiteColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppPalettes.whiteColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      centerTitle: false,
      title: title != null
          ? Text(
              title,
              style: AppStyles.headlineSmall,
            ).horizontalPadding(Dimens.paddingX3)
          : null,
    );
  }
}
