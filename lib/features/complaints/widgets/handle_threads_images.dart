import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/lok_varta/widgets/photo_view_widget.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart'
    as threads;

class HandleThreadsImages extends StatelessWidget {
  final List<threads.Attachments> attachment;
  const HandleThreadsImages({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    final List<String> documents = [];
    for (var index in attachment) {
      documents.add(index.url ?? "");
    }

    if (documents.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhotoViewWidget(photos: documents, index: 0),
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 4 / 5.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.radiusX2),
            child: CommonHelpers.getCacheNetworkImage(
              documents.first,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    if (documents.length == 2) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        cacheExtent: 0,
        padding: EdgeInsets.zero,
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 4,
          crossAxisSpacing: Dimens.gapX2,
          mainAxisSpacing: Dimens.gapX2,
          pattern: [QuiltedGridTile(4, 2), QuiltedGridTile(4, 2)],
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(Dimens.radiusX2),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PhotoViewWidget(photos: documents, index: index),
                ),
              ),
              child: CommonHelpers.getCacheNetworkImage(
                documents[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        itemCount: documents.length,
      );
    }
    if (documents.length == 3) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        cacheExtent: 0,
        padding: EdgeInsets.zero,
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 4,
          crossAxisSpacing: Dimens.gapX2,
          mainAxisSpacing: Dimens.gapX2,
          pattern: [
            QuiltedGridTile(2, 2),
            QuiltedGridTile(2, 2),
            QuiltedGridTile(3, 4),
          ],
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(Dimens.radiusX2),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PhotoViewWidget(photos: documents, index: index),
                ),
              ),
              child: CommonHelpers.getCacheNetworkImage(
                documents[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        itemCount: documents.length,
      );
    } else if (documents.length == 4) {
      return GridView.builder(
        padding: EdgeInsets.only(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Dimens.gapX2,
          mainAxisSpacing: Dimens.gapX2,
          childAspectRatio: 1,
        ),
        itemCount: 4,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(Dimens.radiusX2),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PhotoViewWidget(photos: documents, index: index),
                ),
              ),
              child: CommonHelpers.getCacheNetworkImage(
                documents[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.only(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Dimens.gapX2,
          mainAxisSpacing: Dimens.gapX2,
          childAspectRatio: 1,
        ),
        itemCount: 4,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PhotoViewWidget(photos: documents, index: index),
              ),
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(Dimens.radiusX2),
                  child: CommonHelpers.getCacheNetworkImage(
                    documents[index],
                    fit: BoxFit.cover,
                  ),
                ),
                if (index == 3)
                  Container(
                    width: double.infinity,
                    height: Dimens.scaleX15,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(Dimens.radiusX2),
                    ),
                    child: Center(
                      child: Text(
                        '+${documents.length - 4}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }
}
