import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Dimens.gapX2,
                children: [
                  Row(
                    spacing: Dimens.gapX2,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        spacing: Dimens.gapX1,
                        children: [
                          CommonHelpers.buildStatus(
                            media.createdAt?.toRelativeTime() ?? "unknown Date",
                            statusColor: AppPalettes.liteGreenColor,
                            opacity: 1,
                          ),
                        ],
                      ),
                      if (media.url != null)
                        CommonHelpers.buildIcons(
                          onTap: () {
                            CommonHelpers.shareURL(media.url ?? "", eventId: media.sId);
                          },
                          path: AppImages.shareIcon,
                          color: AppPalettes.liteBlueColor,
                          padding: Dimens.paddingX1B,
                          iconSize: Dimens.scaleX1B,
                        ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimens.gapX2B,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: Dimens.marginX1),
                        height: 70.height(),
                        width: 70.height(),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Dimens.gapX1,
                          children: [
                            TranslatedText(
                              text: media.title ?? "unknown title",
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            ReadMoreWidget(
                              text: media.content ??
                                  "No content available at the moment",
                              maxLines: 2,
                              
                            ),
                          ],
                        ),
                      ),
                    ],
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
