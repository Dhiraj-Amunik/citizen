import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/default_tabbar.dart';

class LokVartaTabbar extends StatelessWidget {
  final TabController controller;
  const LokVartaTabbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;

    return SliverAppBar(
      expandedHeight: 90.height(),
      collapsedHeight: 90.height(),
      backgroundColor: AppPalettes.liteGreenColor,
      flexibleSpace: Container(
        alignment: Alignment.center,
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX7,
          disableBottomRadius: true,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizeBox.sizeHX5,
            Text(
              localization.lok_varta,
              style: context.textTheme.headlineSmall,
            ),
            SizeBox.sizeHX4,
            DefaultTabBar(
              isScrollable: true,
              controller: controller,
              tabLabels: const [
                "Press Releases",
                "Interviews",
                "Articles",
                "Videos",
                "Photo",
              ],
            ),
          ],
        ),
      ),
      pinned: true,
      automaticallyImplyLeading: false,
    );
  }
}
