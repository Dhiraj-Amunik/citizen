import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

class DisclaimerNotice extends StatelessWidget {
  final Function()? onDismiss;

  const DisclaimerNotice({super.key, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
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
                TranslatedText(
                  text: localization.important_notice,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                SizeBox.sizeHX2,
                TranslatedText(
                  text: localization.disclaimer_description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              if (onDismiss != null) {
                onDismiss!();
              } else {
                Navigator.pop(context);
              }
            },

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
