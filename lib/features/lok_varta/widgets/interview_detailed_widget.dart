import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/responisve_image_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;

class InterviewDetailedWidget extends StatelessWidget {
  final model.Media media;

  const InterviewDetailedWidget({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    return Scaffold(
      appBar: commonAppBar(
        action: [
          CommonHelpers.buildIcons(
            path: AppImages.shareIcon,
            color: AppPalettes.liteGreenColor,
            iconColor: AppPalettes.blackColor,
            padding: Dimens.paddingX2,
            iconSize: Dimens.scaleX2,
            onTap: () => CommonHelpers.shareArticleDetails(
              title: media.title,
              summary: media.content,
              date: media.createdAt?.toDdMmmYyyy(),
              url: media.url,
              eventId: media.sId,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
          child: Column(
            children: [
              SizedBox(
                width: 0.8.screenWidth,
                child: TranslatedText(
                  text: media.title.isNull(localization.not_found),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              SizeBox.sizeHX2,
              ReadMoreWidget(
                maxLines: 4,
                text: media.content.isNull(localization.not_found),
              ),
              SizeBox.sizeHX2,
              Text(
                media.createdAt?.toDdMmmYyyy() ?? "unknown Date",
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
              SizeBox.sizeHX2,
              if (media.images?.isNotEmpty == true)
                Row(
                  children: [
                    Text(
                      localization.images,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              SizeBox.sizeHX2,
              if (media.images?.isNotEmpty == true)
                ResponisveImageWidget(images: media.images ?? []),
              SizeBox.sizeHX6,
            ],
          ),
        ),
      ),
    );
  }
}
