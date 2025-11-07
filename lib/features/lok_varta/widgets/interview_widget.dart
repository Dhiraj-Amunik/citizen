import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/widgets/lokvarta_helpers.dart';

class InterviewWidget extends StatelessWidget {
  final List<model.Media> medias;
  final Future<void> Function() onRefresh;

  const InterviewWidget({
    super.key,
    required this.medias,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    if (medias.isEmpty) {
      return LokvartaHelpers.lokVartaPlaceholder(
        type: LokVartaFilter.Interview,
        onRefresh: onRefresh,
      );
    }
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Dimens.paddingX2B,
                vertical: Dimens.paddingX,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.paddingX3,
                vertical: Dimens.paddingX3,
              ),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX2,
                border: Border.all(color: AppPalettes.primaryColor),
                spreadRadius: 2,
                blurRadius: 2,
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final media = medias[index];
                  return GestureDetector(
                    onTap: () => RouteManager.pushNamed(
                      Routes.interviewDetailedPage,
                      arguments: media,
                    ),
                    child: Row(
                      spacing: Dimens.gapX2,

                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Dimens.gapX,
                            children: [
                              Text(
                                media.createdAt?.toDdMmmYyyy() ??
                                    "unknown Date",
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
                                constraints: BoxConstraints(
                                  minHeight: 40.height(),
                                ),
                                child: Text(
                                  media.content ??
                                      "no content available at the moment",
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppPalettes.lightTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 80.height(),
                          height: 80.height(),
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(
                              Dimens.radiusX2,
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
                  );
                },
                separatorBuilder: (_, _) => LokvartaHelpers.lokVartaDivider(),
                itemCount: medias.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
