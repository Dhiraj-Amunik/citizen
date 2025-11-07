import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewWidget extends StatelessWidget {
  final List<String>? photos;
  final int index;

  const PhotoViewWidget({super.key, required this.photos, required this.index});

  @override
  Widget build(BuildContext context) {
    int urlIndex = index;
    return Scaffold(
      backgroundColor: AppPalettes.blackColor,
      appBar: commonAppBar(
        bgColor: AppPalettes.blackColor,
        statusBarColor: AppPalettes.blackColor,
        statusBarMode: Brightness.light,
        iconColor: AppPalettes.whiteColor,
        action: [
          CommonHelpers.buildIcons(
            path: AppImages.shareIcon,
            color: AppPalettes.whiteColor,
            iconColor: AppPalettes.blackColor,
            padding: Dimens.paddingX3,
            iconSize: Dimens.scaleX2,
            onTap: () => CommonHelpers.shareImageUsingLink(
              url: photos![urlIndex],
              description: photos?[urlIndex].toString(),
            ),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: photos?.length,
        builder: (context, index) {
          urlIndex = index;
          return PhotoViewGalleryPageOptions.customChild(
            child: CachedNetworkImage(
              imageUrl: photos?[index] ?? '',
              placeholder: (context, url) => Container(color: Colors.grey),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.red.shade400),
            ),
            minScale: PhotoViewComputedScale.covered,
            heroAttributes: PhotoViewHeroAttributes(tag: photos?[index] ?? ''),
          );
        },
        pageController: PageController(initialPage: index),
        enableRotation: false,
      ),
    );
  }
}
