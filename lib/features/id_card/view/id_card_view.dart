import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/id_card/view_model.dart/id_card_view_model.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IdCardView extends StatelessWidget {
  const IdCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<QrCodeViewModel>();
    return Scaffold(
      appBar: commonAppBar(title: localization.id_card),
      body: RepaintBoundary(
        key: provider.qrKey,
        child: Container(
          decoration: boxDecorationRoundedWithShadow(
            Dimens.radiusX2,
            spreadRadius: 2,
            blurRadius: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX4,
            vertical: Dimens.paddingX4,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.appBarSpacing,
          ),
          child: Column(
            spacing: Dimens.gapX5,
            children: [
              Row(
                spacing: Dimens.gapX4,
                children: [
                  SizedBox(
                    height: Dimens.scaleX10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(Dimens.radius100),
                      ),
                      child: CommonHelpers.getCacheNetworkImage(
                        "https://media.gettyimages.com/id/164928990/photo/young-woman-portrait.jpg?s=612x612&w=0&k=20&c=c9tonf-iDbD5Ig85gsIZxZ_ws1nksxQBgeUwMs2_sKM=",
                      ),
                    ),
                  ),
                  Column(
                    spacing: Dimens.gapX1,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Uday Kiran",
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${localization.membership_id} : CT389",
                        style: textTheme.bodySmall,
                      ),
                      Text("9877363636", style: textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                height: 200.height(),
                padding: EdgeInsets.all(Dimens.paddingX3),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX2,
                  border: Border.all(width: 1),
                  blurRadius: 2,
                  spreadRadius: 2,
                ),
                child: QrImageView(
                  data: "User Name",
                  padding: const EdgeInsets.all(0),
                  // embeddedImage: const AssetImage(AppImages.qrLogo),
                  // embeddedImageStyle: QrEmbeddedImageStyle(size: Size(30, 30)),
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: Dimens.gapX3,
                children: [
                  CommonButton(
                    onTap: () {},
                    height: 0,
                    fullWidth: false,
                    fontSize: 14,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimens.paddingX2,
                      horizontal: Dimens.paddingX4,
                    ),
                    child: Row(
                      children: [
                        CommonHelpers.buildIcons(
                          path: AppImages.shareIcon,
                          onTap: () => provider.shareQrCode(),
                        ),
                        Text(
                          localization.share,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppPalettes.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CommonButton(
                    onTap: () {},
                    fullWidth: false,
                    textColor: AppPalettes.primaryColor,
                    color: AppPalettes.liteGreyColor,
                    fontSize: 14,
                    elevation: 0.1,
                    height: 0,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimens.paddingX2,
                      horizontal: Dimens.paddingX4,
                    ),
                    child: Row(
                      children: [
                        CommonHelpers.buildIcons(
                          path: AppImages.downnloadIcon,
                          iconColor: AppPalettes.primaryColor,
                        ),
                        Text(
                          localization.download,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppPalettes.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
