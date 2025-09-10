import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
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
    return Column(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            padding:  EdgeInsets.symmetric(
            horizontal: Dimens.paddingX2B,
          ),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final media = medias[index];
          
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX3,
                  vertical: Dimens.paddingX3,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX5,
                  spreadRadius: 2,
                  blurRadius: 2,
                  border: Border.all(width: 1,color: AppPalettes.primaryColor)
                ),
                child: Row(
                  spacing: Dimens.gapX2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/logo/login_image.png", height: 60),
                    Expanded(
                      child: Column(
                        spacing: Dimens.gapX1,
                        crossAxisAlignment: CrossAxisAlignment.start,
          
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  media.title ?? "unknown title",
                                  style: textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimens.paddingX2,
                                    vertical: Dimens.paddingX1,
                                  ),
                                  decoration: boxDecorationRoundedWithShadow(
                                    Dimens.radius100,
                                    backgroundColor:
                                        AppPalettes.liteGreenTextFieldColor,
                                  ),
                                  child: Text(
                                    media.createdAt?.toRelativeTime() ??
                                        "unknown Date",
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppPalettes.lightTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
          
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 20.height(),
                            ),
                            child: Text(
                              media.content ??
                                  "no content available at the moment",
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.lightTextColor,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, _) => SizeBox.widgetSpacing,
            itemCount: medias.length,
          ),
        ),
      ],
    );
  }
}
