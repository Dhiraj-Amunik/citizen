import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/animated_search_widget.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/default_tabbar.dart';

class LokVartaTabbar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String index) onSearchChanged;
  final Function()? onClear;
  final TabController controller;
  final Function()? onTap;
  final bool showSearch;
  const LokVartaTabbar({
    super.key,
    required this.controller,
    required this.onTap,
    required this.showSearch,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;

    const double toolbarHeight = 160;
    return SliverAppBar(
      expandedHeight: toolbarHeight.height(),
      collapsedHeight: toolbarHeight.height(),
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
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localization.lok_varta,
                      style: context.textTheme.headlineSmall,
                    ),
                  ],
                ),
                if (!showSearch)
                  CommonHelpers.buildIcons(
                    color: AppPalettes.liteGreenColor,
                    padding: Dimens.paddingX2,
                    path: AppImages.searchIcon,
                    iconColor: AppPalettes.blackColor,
                    onTap: onTap,
                  ).onlyPadding(right: Dimens.horizontalspacing),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: showSearch ? 52.height() : 12.height(),
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.horizontalspacing,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: showSearch
                    ? AnimatedSearchBar(
                        key: const ValueKey('search_bar'),
                        controller: searchController,
                        onChanged: onSearchChanged,
                        onClear: onClear,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_search')),
              ),
            ),
            SizeBox.sizeHX2,
            DefaultTabBar(
              isScrollable: true,
              controller: controller,
              tabLabels: const [
                "Upcoming Events",
                "Ongoing Events",
                "Press Releases",
                "Interviews & Articles",
                "Videos",
                "Photos",
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
