import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class DonationDialog extends StatelessWidget {
  const DonationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX6,
        vertical: Dimens.paddingX5,
      ).copyWith(top: Dimens.paddingX4B),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        backgroundColor: AppPalettes.liteGreyColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Dimens.gapX3,
        children: <Widget>[
          Text(localization.donate_for, style: textTheme.headlineSmall),

          Text(
            localization.donate_for_description,
            style: textTheme.labelMedium?.copyWith(
              color: AppPalettes.lightTextColor,
              wordSpacing: Dimens.gapX,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
