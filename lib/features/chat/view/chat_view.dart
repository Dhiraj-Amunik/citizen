import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/animated_search_widget.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;

  static const List<String> _tabTitles = [
    "Wall of help",
    "Near me",
  ];

  static const List<Widget> _tabChildren = [
    _ChatTabPlaceholder(title: "Wall of help"),
    _ChatTabPlaceholder(title: "Near me"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabTitles.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 180),
    );
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: commonAppBar(title: "Chat"),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: Dimens.horizontalspacing,
              right: Dimens.horizontalspacing,
              top: Dimens.paddingX4,
              bottom: Dimens.paddingX3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
                SizedBox(height: Dimens.paddingX2),
                SizedBox(
                  height: Dimens.paddingX8,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.transparent,
                    labelColor: AppPalettes.primaryColor,
                    unselectedLabelColor: AppPalettes.blackColor,
                    labelStyle: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: textTheme.bodyMedium,
                    dividerColor: Colors.transparent,
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: Dimens.paddingX1,
                    ),
                    overlayColor:
                        WidgetStateProperty.all(AppPalettes.transparentColor),
                    tabs: List.generate(
                      _tabTitles.length,
                      (index) => _ChipTab(
                        controller: _tabController,
                        index: index,
                        text: _tabTitles[index],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabChildren,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTabPlaceholder extends StatelessWidget {
  final String title;
  const _ChatTabPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("$title tab content coming soon"),
    );
  }
}

class _ChipTab extends StatelessWidget {
  final TabController controller;
  final int index;
  final String text;
  const _ChipTab({
    required this.controller,
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: AnimatedBuilder(
        animation: controller.animation ?? controller,
        builder: (context, _) {
          final double animationValue =
              controller.animation?.value ?? controller.index.toDouble();
          final double uiValue = animationValue.clamp(0.0, controller.length - 1);
          final double clampedDistance = (uiValue - index).abs().clamp(0.0, 1.0);
          final double intensity = (1 - clampedDistance).clamp(0.0, 1.0);
          final double fillOpacity = 0.3 * intensity;
          final double borderOpacity = 0.25 + (0.05 * intensity);

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.paddingX3,
              vertical: Dimens.padding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimens.radius100),
              color: AppPalettes.primaryColor.withOpacity(fillOpacity),
              border: Border.all(
                color: AppPalettes.primaryColor.withOpacity(borderOpacity),
                width: Dimens.borderWidth / 2,
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(text, style: context.textTheme.bodySmall?.copyWith(
                color: index == controller.index ? AppPalettes.primaryColor : AppPalettes.blackColor,
              )),
            ),
          );
        },
      ),
    );
  }
}
