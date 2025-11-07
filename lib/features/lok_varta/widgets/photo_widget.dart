import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/widgets/lokvarta_helpers.dart';

class PhotoWidget extends StatelessWidget {
  final List<model.Media> medias;
  final Future<void> Function() onRefresh;

  const PhotoWidget({super.key, required this.medias, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final singleMediaImgs = <PhotoModel>[];
    for (final media in medias) {
      if (media.images != null && media.images!.isNotEmpty) {
        if (media.images!.length <= 1) {
          singleMediaImgs.add(
            PhotoModel(
              url: media.images?.first ?? " ",
              title: media.title,
              multipleImages: false,
              data: media,
            ),
          );
        } else {
          singleMediaImgs.add(
            PhotoModel(
              url: media.images?.first ?? " ",
              title: media.title,
              multipleImages: true,
              data: media,
            ),
          );
        }
      }
    }

    if (medias.isEmpty) {
      return LokvartaHelpers.lokVartaPlaceholder(
        type: LokVartaFilter.PhotoGallery,
        onRefresh: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        cacheExtent: 0,
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX2B,
        ).copyWith(bottom: Dimens.paddingX15),
         gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        pattern: _getGridPattern(singleMediaImgs.length),
      ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => RouteManager.pushNamed(
              Routes.photoDetailsPage,
              arguments: singleMediaImgs[index].data,
            ),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(Dimens.radiusX2),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  CommonHelpers.getCacheNetworkImage(
                    singleMediaImgs[index].url,
                    fit: BoxFit.cover,
                  ),

                  if (singleMediaImgs[index].title != null)
                    Align(
                      alignment: AlignmentGeometry.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.paddingX1,
                          horizontal: Dimens.paddingX2,
                        ),
                        constraints: BoxConstraints(maxWidth: double.infinity),
                        color: AppPalettes.blackColor.withOpacityExt(0.5),
                        child: Text(
                          singleMediaImgs[index].title!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppPalettes.whiteColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (singleMediaImgs[index].multipleImages == true)
                    Align(
                      alignment: AlignmentGeometry.topRight,
                      child: CommonHelpers.buildIcons(
                        path: AppImages.stackIcon,
                        iconSize: Dimens.scaleX7,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        itemCount: singleMediaImgs.length,
      ),
    );
  }
}

class PhotoModel {
  final String url;
  final String? title;
  final bool? multipleImages;
  final model.Media data;

  const PhotoModel({
    required this.url,
    this.title,
    this.multipleImages,
    required this.data,
  });
}



List<QuiltedGridTile> _getGridPattern(int itemCount) {
  // Define all the base patterns
  final patterns = {
    1: [const QuiltedGridTile(4, 4)],
    2: [const QuiltedGridTile(4, 2), const QuiltedGridTile(4, 2)],
    3: [
      const QuiltedGridTile(4, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(2, 2),
    ],
    4: [
      const QuiltedGridTile(3, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(3, 2),
      const QuiltedGridTile(2, 2),
    ],
    5: [
      const QuiltedGridTile(3, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(1, 2),
    ],
    6: [
      const QuiltedGridTile(3, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(3, 2),
      const QuiltedGridTile(1, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(1, 2),
    ],
  };

  // For 1-6 items, return the direct pattern
  if (itemCount <= 6) {
    return patterns[itemCount]!;
  }

  // For 7+ items, combine patterns additively
  List<QuiltedGridTile> result = [];
  int remaining = itemCount;

  // Keep adding patterns until we've covered all items
  while (remaining > 0) {
    if (remaining >= 6) {
      // Add full case 6 pattern
      result.addAll(patterns[6]!);
      remaining -= 6;
    } else {
      // Add the remaining pattern (case 1-5)
      result.addAll(patterns[remaining]!);
      remaining = 0;
    }
  }

  return result;
}