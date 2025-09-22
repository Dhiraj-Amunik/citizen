import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/lok_varta/model/mla_details_model.dart'
    as mladetails;

class MlaDetailsSilverAppbar extends StatelessWidget {
  final mladetails.Mla? mlaModel;
  const MlaDetailsSilverAppbar({super.key, this.mlaModel});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppPalettes.liteGreenColor,
      pinned: true,
      expandedHeight: 130.height(),
      collapsedHeight: 90.height(),
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          vertical: Dimens.paddingX4,
          horizontal: Dimens.horizontalspacing,
        ),
        title: Row(
          spacing: Dimens.gapX2B,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(Dimens.radius100),
              child: SizedBox(
                height: Dimens.scaleX8,
                width: Dimens.scaleX8,
                child: CommonHelpers.getCacheNetworkImage(
                  mlaModel?.user?.avatar,
                ),
              ),
            ),
            Expanded(
              child: Column(
                spacing: Dimens.gapX1B,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        mlaModel?.user?.name ?? "...",
                        style: textTheme.headlineMedium,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  Row(
                    spacing: Dimens.gapX1B,
                    children: [
                      SvgPicture.asset(
                        "assets/lok_varta/ii.svg",
                        height: Dimens.scaleX2B,
                      ),
                      SvgPicture.asset(
                        "assets/lok_varta/fi.svg",
                        height: Dimens.scaleX2B,
                      ),
                      SvgPicture.asset(
                        "assets/lok_varta/ti.svg",
                        height: Dimens.scaleX2B,
                      ),
                      SvgPicture.asset(
                        "assets/lok_varta/yi.svg",
                        height: Dimens.scaleX2B,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
