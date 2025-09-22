import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';

class PressReleasesDetailedView extends StatelessWidget {
  const PressReleasesDetailedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalettes.whiteColor,
      appBar: commonAppBar(title: 'New App Features', center: true),
      body:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60.h,
                backgroundImage: AssetImage(AppImages.partyImage),
              ),
              SizedBox(height: Dimens.widgetSpacing),
              Text('New App Features', style: context.textTheme.titleMedium),
              SizedBox(height: Dimens.radiusX1),
              Text('15-10-2025', style: context.textTheme.bodySmall),
              SizedBox(height: Dimens.gapX2),
              Text(
                'We\'ve added new features to make reporting issues even easier. Check out the latest updates! We\'ve added new features to make reporting issues even easier. Check out the latest updates! We\'ve added new features to make reporting issues even easier. Check out the latest updates!',
                style: context.textTheme.bodySmall,
              ),
              SizedBox(height: Dimens.widgetSpacing),
              Row(
                children: [
                  Text('Images', style: context.textTheme.titleMedium),
                ],
              ),
              SizedBox(height: Dimens.widgetSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: Dimens.gapX3,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(
                      Dimens.radiusX3,
                    ),
                    child: Image.asset(
                      AppImages.imagePlaceholder,
                      width: 120.w,
                      height: 120.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(
                      Dimens.radiusX3,
                    ),
                    child: Image.asset(
                      AppImages.imagePlaceholder,
                      width: 120.w,
                      height: 120.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              Spacer(),
              CommonButton(text: 'Share', onTap: () => RouteManager.pop()),
            ],
          ).symmetricPadding(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.verticalspacing,
          ),
    );
  }
}
