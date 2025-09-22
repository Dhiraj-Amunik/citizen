import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class DisclaimerNotice extends StatelessWidget {
  final Function()? onDismiss;

  const DisclaimerNotice({super.key, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX4),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        spacing: Dimens.gapX3,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber[700],
            size: Dimens.scaleX3,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Important Notice",
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                SizeBox.sizeHX2,
                Text(
                  "This app is developed for the Citizens and is not an official government app. It is intended for public grievance reporting and citizen engagement purposes only.",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              padding: EdgeInsets.all(Dimens.paddingX1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: AppPalettes.redColor),
              ),
              child: Icon(Icons.close, color: AppPalettes.redColor),
            ),
          ),
        ],
      ),
    );
  }
}
