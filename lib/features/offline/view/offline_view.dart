import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AuthUtils.appbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 0.3.screenHeight),
          Icon(Icons.cloud_off_outlined, size: Dimens.scaleX6),
          SizeBox.sizeHX2,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You're Offline",
                style: textTheme.headlineMedium?.copyWith(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizeBox.sizeHX1,
          Text(
            "Please connect to the internet and try again.",
            style: textTheme.bodyMedium?.copyWith(letterSpacing: 1),
            textAlign: TextAlign.center,
          ).symmetricPadding(horizontal: Dimens.paddingX10),
        ],
      ),
    );
  }
}
