import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/navigation/model/navigation_model.dart';

class TabIconWidget extends StatelessWidget {
  final NavigationModel data;
  final VoidCallback onTap;
  final bool isSelected;
  const TabIconWidget({
    super.key,
    required this.data,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing:
              (data.imagePath != null && data.imagePath!.endsWith("png")) ==
                  true
              ? Dimens.gapX1
              : Dimens.gapX2,
          children: [
            if (data.imagePath != null && data.imagePath!.endsWith("png"))
              Image.asset(
                data.imagePath!,
                height: Dimens.scaleX3B,
              ),
            if (data.imagePath != null && data.imagePath!.endsWith("svg"))
              SvgPicture.asset(
                data.imagePath!,
                height: Dimens.scaleX2B,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? AppPalettes.primaryColor
                      : AppPalettes.blackColor,
                  BlendMode.srcIn,
                ),
              ),
            Text(
              data.text!,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppPalettes.primaryColor
                    : AppPalettes.blackColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
