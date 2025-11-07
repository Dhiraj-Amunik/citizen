import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
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
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;
import 'package:inldsevak/features/lok_varta/view_model/lok_varta_view_model.dart';
import 'package:provider/provider.dart';

class PhotoDetailsView extends StatelessWidget {
  final model.Media media;

  const PhotoDetailsView({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    final provider = context.read<LokVartaViewModel>();

    return Scaffold(
      appBar: commonAppBar(
        action: [
          Consumer<LokVartaViewModel>(
            builder: (context, value, _) {
              if (value.showShareIcon) {
                return CommonHelpers.buildIcons(
                  path: AppImages.shareIcon,
                  color: AppPalettes.liteGreenColor,
                  iconColor: AppPalettes.blackColor,
                  padding: Dimens.paddingX3,
                  iconSize: Dimens.scaleX2,
                  onTap: () => CommonHelpers.shareURL(media.url ?? ""),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.paddingX2,
        ),
        child: FutureBuilder(
          future: provider.getLokVartaDetails(media.sId ?? ""),
          builder: (context, snapshot) {
            final media = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomAnimatedLoading());
            }
            if (media == null) {
              return Center(child: Text("Lok Varta not Found !"));
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: 0.8.screenWidth,
                    child: Text(
                      media.title.isNull(localization.not_found),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeBox.sizeHX,
                  Text(
                    media.createdAt?.toDdMmYyyy() ??
                        DateTime.now().toString().toDdMmYyyy(),
                    style: textTheme.titleMedium?.copyWith(
                      color: AppPalettes.lightTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ReadMoreWidget(
                    maxLines: 4,
                    text: media.content.isNull(localization.not_found),
                  ),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
