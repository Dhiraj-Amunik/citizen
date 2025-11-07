import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart' show SizeBox;
import 'package:inldsevak/core/widgets/common_button.dart';

class CustomContainerWidget extends StatelessWidget {
  final Routes route;
  final String buttonText;
  final String heading;
  final String desciption;
  const CustomContainerWidget({
    super.key,
    required this.route,
    required this.heading,
    required this.desciption,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        backgroundColor: AppPalettes.greenColor.withOpacityExt(0.2),
        Dimens.radiusX5,
        spreadRadius: 2,
        blurRadius: 2,
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(heading, style: textTheme.bodyMedium),
              SizeBox.sizeHX1,
              Text(
                desciption,
                style: textTheme.labelMedium?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
              SizeBox.sizeHX8,
            ],
          ).onlyPadding(bottom: Dimens.paddingX2),
          CommonButton(
            fullWidth: false,
            height: 30,
            padding: EdgeInsets.symmetric(
              vertical: Dimens.paddingX1,
              horizontal: Dimens.paddingX3,
            ),
            onTap: () => RouteManager.pushNamed(route),
            text:buttonText,
            color: AppPalettes.buttonColor,
          ),
        ],
      ),
    );
  }
}
