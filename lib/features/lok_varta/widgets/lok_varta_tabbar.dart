import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/animated_widgets.dart/animated_search_widget.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
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

    // Dynamic height based on search visibility
    // Content breakdown (from error analysis - actual measured values):
    // - Top spacing: 8.8px (Dimens.gapX2)
    // - Title/icon: 40.5px
    // - Search (when visible): 48.2px (44.sp renders as 48.2px)
    // - Spacing: 2.2px (Dimens.gapX)
    // - TabBar: 31.8px
    // Total with search: 131.5px, Without search: ~83px
    // Current SliverAppBar is 120.4px but needs 131.5px (11px short)
    // Increasing slightly to prevent overflow while keeping Column at min size
    // Base height for title area + tabs + top/bottom padding
    final double baseHeight = 100.sp;
    // Search height = search bar (44) + top margin (8) + bottom margin (8) + buffer
    final double searchHeight = showSearch ? 60.sp : 0;
    final double toolbarHeight = baseHeight + searchHeight;

    return SliverAppBar(
      expandedHeight: toolbarHeight,
      collapsedHeight: toolbarHeight,
      backgroundColor: AppPalettes.liteGreenColor,
      flexibleSpace: Container(
        alignment: Alignment.topCenter,
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX7,
          disableBottomRadius: true,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: Dimens.gapX2.toDouble()),
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
                    iconSize: 18.sp,
                    onTap: onTap,
                  ).onlyPadding(right: Dimens.horizontalspacing),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: showSearch ? 55.sp : 0,
              margin: showSearch
                  ? EdgeInsets.symmetric(vertical: Dimens.gapX2)
                  : EdgeInsets.zero,
              padding: showSearch ? EdgeInsets.zero : EdgeInsets.zero,
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
            SizedBox(height: Dimens.gapX.toDouble()),
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
