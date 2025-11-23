import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/url_launcher.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/responisve_image_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;

class PressReleasesDetailedView extends StatelessWidget {
  final model.Media media;
  const PressReleasesDetailedView({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Scaffold(
      backgroundColor: AppPalettes.whiteColor,
      appBar: commonAppBar(
        title: localization.lok_varta,
        action: [
          if (media.url != null)
            CommonHelpers.buildIcons(
              path: AppImages.shareIcon,
              color: AppPalettes.liteGreenColor,
              iconColor: AppPalettes.blackColor,
              padding: Dimens.paddingX3,
              iconSize: Dimens.scaleX2B,
              onTap: () => CommonHelpers.shareURL(media.url ?? "", eventId: media.sId),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.paddingX2,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: Dimens.scaleX15,
                width: Dimens.scaleX15,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(Dimens.radius100),
                  child: CommonHelpers.getCacheNetworkImage(
                    media.images?.isEmpty == true ? "" : media.images?.first,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizeBox.sizeHX2,
              SizedBox(
                width: 0.8.screenWidth,
                child: TranslatedText(
                  text: media.title ?? "Unknown title",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizeBox.sizeHX2,
              ReadMoreWidget(
                maxLines: 4,
                text: media.content ?? "Unknown description",
              ),
              SizeBox.sizeHX2,
              if (media.images?.isNotEmpty == true)
                Row(
                  children: [
                    TranslatedText(
                      text: 'Images',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              SizeBox.sizeHX2,
              if (media.images?.isNotEmpty == true)
                ResponisveImageWidget(images: media.images ?? []),
            ],
          ),
        ),
      ),
      bottomNavigationBar: (media.url == null)
          ? SizedBox()
          : CommonButton(
              text: 'View News',
              onTap: () {
                UrlLauncher().launchURL(media.url);
              },
            ).symmetricPadding(
              horizontal: Dimens.horizontalspacing,
              vertical: Dimens.verticalspacing,
            ),
    );
  }
}
