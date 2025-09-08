import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
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
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Dimens.paddingX2B,
              vertical: Dimens.appBarSpacing,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.paddingX3,
              vertical: Dimens.paddingX3,
            ),
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX2,
              spreadRadius: 2,
              blurRadius: 2,
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final media = medias[index];

                return Row(
                  spacing: Dimens.gapX2,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: Dimens.gapX,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            media.createdAt?.toRelativeTime() ?? "unknown Date",
                            style: textTheme.labelSmall?.copyWith(
                              color: AppPalettes.lightTextColor,
                            ),
                          ),
                          Text(
                            media.title ?? "unknown title",
                            style: textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 40.height()),
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
                    Image.asset("assets/logo/login_image.png", height: 60),
                  ],
                );
              },
              separatorBuilder: (_, _) => LokvartaHelpers.lokVartaDivider(),
              itemCount: medias.length,
            ),
          ),
        ),
      ],
    );
  }
}
