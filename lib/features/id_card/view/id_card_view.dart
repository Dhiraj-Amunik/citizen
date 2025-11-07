import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/id_card/view_model.dart/id_card_view_model.dart';
import 'package:inldsevak/features/id_card/widgets/id_card_widget.dart';
import 'package:inldsevak/features/id_card/widgets/user_detail_widget.dart';
import 'package:inldsevak/features/navigation/view/navigation_view.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class IdCardView extends StatelessWidget {
  const IdCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<QrCodeViewModel>();
    final userProfile = context.read<ProfileViewModel>();
    return Scaffold(
      appBar: commonAppBar(title: localization.id_card, elevation: 2),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing,vertical: Dimens.paddingX6),
        child: RepaintBoundary(
          key: provider.qrKey,
          child: Container(
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX4,
              border: Border.all(color: AppPalettes.primaryColor, width: 1),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.paddingX6,
              vertical: Dimens.paddingX6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Dimens.gapX8,
              children: [
                UserDetailWidget(
                  heading: textTheme.bodyLarge,
                  scale: Dimens.scaleX10,
                  profile: userProfile.profile,
                ),
                QrCodeWidget(
                  height: 200,
                  data: userProfile.profile?.membershipId ?? "",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: Dimens.gapX3,
                  children: [
                    Expanded(
                      child: CommonButton(
                        onTap: () => provider.downloadFile(),
                        height: 45.height(),
                        borderColor: AppPalettes.primaryColor,
                        color: AppPalettes.whiteColor,
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.paddingX2,
                          horizontal: Dimens.paddingX4,
                        ),
                        child: Row(
                          spacing: Dimens.gapX1B,
                          children: [
                            CommonHelpers.buildIcons(
                              iconSize: Dimens.scaleX1B,
                              path: AppImages.downnloadIcon,
                              iconColor: AppPalettes.primaryColor,
                            ),
                            Text(
                              localization.download,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: CommonButton(
                        onTap: () => provider.shareQrCode(),
                        height: 45.height(),
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.paddingX2,
                          horizontal: Dimens.paddingX4,
                        ),

                        child: Row(
                          spacing: Dimens.gapX1,
                          children: [
                            CommonHelpers.buildIcons(
                              iconSize: Dimens.scaleX1,
                              path: AppImages.shareIcon,
                              iconColor: AppPalettes.whiteColor,
                            ),
                            Text(
                              localization.share,
                              style: textTheme.labelSmall?.copyWith(
                                color: AppPalettes.whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DummyNav(),
    );
  }
}
