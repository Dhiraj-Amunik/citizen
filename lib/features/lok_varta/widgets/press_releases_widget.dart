import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/widgets/lokvarta_helpers.dart';

class PressReleasesWidget extends StatelessWidget {
  final List<model.Media> medias;
  final Future<void> Function() onRefresh;

  const PressReleasesWidget({
    super.key,
    required this.medias,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    if (medias.isEmpty) {
      return LokvartaHelpers.lokVartaPlaceholder(
        type: LokVartaFilter.PressRelease,
        onRefresh: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX2B).copyWith(bottom: Dimens.paddingX15),
        shrinkWrap: true,
        itemBuilder: (_, index) {
          final media = medias[index];
          return GestureDetector(
            onTap: () => RouteManager.pushNamed(
              Routes.pressReleasesDetailedPage,
              arguments: media,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.paddingX3,
                vertical: Dimens.paddingX1B,
              ),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX5,
                spreadRadius: 2,
                blurRadius: 2,
                border: Border.all(width: 1, color: AppPalettes.primaryColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: Dimens.gapX2B,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: Dimens.marginX2),
                        height: 80.height(),
                        width: 80.height(),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            Dimens.radius100,
                          ),
                          child: CommonHelpers.getCacheNetworkImage(
                            media.images?.isEmpty == true
                                ? ""
                                : media.images?.first ?? "",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Dimens.gapX1,
                      children: [
                        Row(
                          spacing: Dimens.gapX2,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CommonHelpers.buildStatus(
                              media.createdAt?.toRelativeTime() ??
                                  "unknown Date",
                              statusColor: AppPalettes.liteGreenColor,
                              opacity: 1,
                            ),
                            if (media.url != null)
                              CommonHelpers.buildIcons(
                                onTap: () {
                                  CommonHelpers.shareURL(media.url ?? "");
                                },
                                path: AppImages.shareIcon,
                                color: AppPalettes.liteBlueColor,
                                padding: Dimens.paddingX1B,
                                iconSize: Dimens.scaleX1B,
                              ).onlyPadding(top: Dimens.paddingX1),
                          ],
                        ),
                        Text(
                          media.title ?? "unknown title",
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text(
                          media.content ?? "no content available at the moment",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppPalettes.lightTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => SizeBox.widgetSpacing,
        itemCount: medias.length,
      ),
    );
  }
}
