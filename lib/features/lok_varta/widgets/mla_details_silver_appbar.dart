import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/url_launcher.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
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
                spacing: Dimens.gapX1,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: TranslatedText(
                        text: mlaModel?.user?.name ?? "...",
                        style: textTheme.headlineMedium,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final links = mlaModel?.socialMediaLinks;
                            if (links != null && links.length > 0) {
                              final url = links[0].url;
                              if (url != null && url.isNotEmpty) {
                                UrlLauncher().launchURL(url);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(Dimens.radiusX2),
                          child: Padding(
                            padding: EdgeInsets.all(Dimens.paddingX1),
                            child: SvgPicture.asset(
                              "assets/lok_varta/ii.svg",
                              height: Dimens.scaleX2B,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final links = mlaModel?.socialMediaLinks;
                            if (links != null && links.length > 1) {
                              final url = links[1].url;
                              if (url != null && url.isNotEmpty) {
                                UrlLauncher().launchURL(url);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(Dimens.radiusX2),
                          child: Padding(
                            padding: EdgeInsets.all(Dimens.paddingX1),
                            child: SvgPicture.asset(
                              "assets/lok_varta/fi.svg",
                              height: Dimens.scaleX2B,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final links = mlaModel?.socialMediaLinks;
                            if (links != null && links.length > 2) {
                              final url = links[2].url;
                              if (url != null && url.isNotEmpty) {
                                UrlLauncher().launchURL(url);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(Dimens.radiusX2),
                          child: Padding(
                            padding: EdgeInsets.all(Dimens.paddingX1),
                            child: SvgPicture.asset(
                              "assets/lok_varta/ti.svg",
                              height: Dimens.scaleX2B,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final links = mlaModel?.socialMediaLinks;
                            if (links != null && links.length > 3) {
                              final url = links[3].url;
                              if (url != null && url.isNotEmpty) {
                                UrlLauncher().launchURL(url);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(Dimens.radiusX2),
                          child: Padding(
                            padding: EdgeInsets.all(Dimens.paddingX1),
                            child: SvgPicture.asset(
                              "assets/lok_varta/yi.svg",
                              height: Dimens.scaleX2B,
                            ),
                          ),
                        ),
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
