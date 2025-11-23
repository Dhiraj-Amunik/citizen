import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

class EventInfoContainer extends StatelessWidget {
  final String icon;
  final String text;
  const EventInfoContainer({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX3,
        backgroundColor: AppPalettes.liteGreyColor,
      ),
      child:
          Row(
            children: [
              CommonHelpers.buildIcons(
                color: AppPalettes.liteGreenColor,
                path: icon,
                iconColor: AppPalettes.primaryColor,
                iconSize: Dimens.scaleX2B,
                padding: Dimens.paddingX2,
              ),
              SizeBox.sizeWX4,
              Flexible(child: TranslatedText(text: text, style: context.textTheme.bodyMedium)),
            ],
          ).symmetricPadding(
            horizontal: Dimens.paddingX3,
            vertical: Dimens.paddingX3,
          ),
    );
  }
}
