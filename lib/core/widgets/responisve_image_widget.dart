import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/lok_varta/widgets/photo_view_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

class ResponisveImageWidget extends StatelessWidget {
  final List<String> images;
  const ResponisveImageWidget({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      cacheExtent: 0,
      padding: EdgeInsets.zero,
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        pattern: _getGridPattern(images.length),
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.radiusX2),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PhotoViewWidget(photos: images, index: index),
              ),
            ),
            child: _buildImageWithSkeleton(images[index]),
          ),
        );
      },
      itemCount:images.length,
    );
  }
}

List<QuiltedGridTile> _getGridPattern(int itemCount) {
  // Define all the base patterns
  final patterns = {
    1: [const QuiltedGridTile(4, 4)],
    2: [const QuiltedGridTile(4, 2), const QuiltedGridTile(4, 2)],
    3: [
      const QuiltedGridTile(4, 2),
      const QuiltedGridTile(4, 2),
      const QuiltedGridTile(4, 4),
    ],
    4: [
      const QuiltedGridTile(4, 2),
      const QuiltedGridTile(4, 2),
      const QuiltedGridTile(4, 2),
      const QuiltedGridTile(4, 2),
    ],
    5: [
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(2, 2),
      const QuiltedGridTile(4, 4),
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

Widget _buildImageWithSkeleton(String imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.cover,
    progressIndicatorBuilder: (context, url, downloadProgress) {
      return _buildSkeletonLoader();
    },
    errorWidget: (context, url, error) {
      return Container(
        color: AppPalettes.imageholderColor,
        child: Icon(
          Icons.image_not_supported,
          color: AppPalettes.lightTextColor,
        ),
      );
    },
  );
}

Widget _buildSkeletonLoader() {
  return Shimmer.fromColors(
    baseColor: AppPalettes.liteGreyColor,
    highlightColor: AppPalettes.whiteColor,
    period: const Duration(milliseconds: 1500),
    child: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppPalettes.liteGreyColor,
        borderRadius: BorderRadius.circular(Dimens.radiusX2),
      ),
    ),
  );
}
