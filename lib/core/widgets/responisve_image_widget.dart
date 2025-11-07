import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/lok_varta/widgets/photo_view_widget.dart';

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
            child: CommonHelpers.getCacheNetworkImage(
              images[index],
              fit: BoxFit.cover,
            ),
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
