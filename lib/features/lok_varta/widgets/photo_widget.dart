import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
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
    final allImages = <String>[];
    for (final media in medias) {
      if (media.images != null && media.images!.isNotEmpty) {
        allImages.addAll(media.images!);
      }
    }

    if (allImages.isEmpty) {
      return LokvartaHelpers.lokVartaPlaceholder(
        type: LokVartaFilter.PhotoGallery,
        onRefresh: onRefresh,
      );
    }
    return GridView.builder(
      cacheExtent: 0,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX2B,
        vertical: Dimens.appBarSpacing,
      ),
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        pattern: [
          QuiltedGridTile(3, 4),
          QuiltedGridTile(3, 2),
          QuiltedGridTile(2, 2),
          QuiltedGridTile(3, 2),
          QuiltedGridTile(2, 2),
        ],
      ),
      itemBuilder: (context, index) {
        return CommonHelpers.getCacheNetworkImage(allImages[index]);
      },
      itemCount: allImages.length,
    );
  }
}
