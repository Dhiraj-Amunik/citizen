import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String text) onChanged;
  final Function()? onClear;

  const AnimatedSearchBar({super.key, required this.onChanged, this.onClear ,required this.controller});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool showSearchField = true;

  static final Color searchButtonColor = AppPalettes.liteGreenColor;

  Color get primaryColor => AppPalettes.liteGreenColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: showSearchField ? Alignment.center : Alignment.centerRight,
      duration: Duration(milliseconds: 500), // Slightly slower - 500ms
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4
      ),
      child: Material(
        shadowColor: AppPalettes.shadowColor,
        borderRadius: BorderRadius.circular(360),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500), // Slightly slower - 500ms
          decoration: BoxDecoration(
            color: showSearchField ? primaryColor : searchButtonColor,
            borderRadius: BorderRadius.circular(360),
          ),
          child: CrossFade(
            show: showSearchField,
            hiddenChild: searchButton(),
            child: searchBar(),
          ),
        ),
      ),
    );
  }

  ///The [TextField & ClearButton] widgets will be placed in this row
  Widget searchBar() {
    return Row(
      children: [
        if (showSearchField)
          opacity(
            duration: Duration(milliseconds: 500), // Slightly slower - 500ms
            child: searchButton(enabled: false),
          ),
        searchField(),
        clearButton(),
      ],
    );
  }

  Widget searchField() {
    return Expanded(
      child: opacity(
        child: TextField(
          controller: widget.controller,
          autofocus: true,
          onChanged: widget.onChanged,
          style: AppStyles.bodyMedium,
          cursorColor: AppPalettes.blackColor,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: AppStyles.bodyMedium,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget searchButton({bool enabled = true}) {
    return GestureDetector(
      onTap: enabled == false
          ? null
          : () {
              if (mounted) setState(() => showSearchField = true);
            },
      child: AnimatedPadding(
        padding: EdgeInsetsGeometry.all(Dimens.paddingX2B),
        duration: Duration(milliseconds: 500), // Slightly slower - 500ms
        child: Icon(
          CupertinoIcons.search,
          color: AppPalettes.primaryColor,
          size: Dimens.scaleX3,
        ),
      ),
    );
  }

  Widget clearButton() {
    return opacity(
      duration: Duration(milliseconds: 500), // Slightly slower - 500ms
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalettes.primaryColor,
          borderRadius: BorderRadius.circular(360),
        ),
        child: GestureDetector(
          onTap: widget.onClear,
          
          // () {
          //   if (mounted) setState(() => showSearchField = false);
          //   widget.onChanged('');
          //   FocusScope.of(context).unfocus();
          // },
          child: Icon(
            CupertinoIcons.clear,
            color: AppPalettes.whiteColor,
            size: Dimens.scaleX2B,
          ).allPadding(Dimens.paddingX3),
        ),
      ),
    );
  }

  Widget opacity({required Widget child, Duration? duration}) {
    return AnimatedOpacity(
      opacity: showSearchField ? 1 : 0,
      duration:
          duration ?? Duration(milliseconds: 500), // Slightly slower - 500ms
      child: child,
    );
  }
}

class CrossFade extends StatelessWidget {
  final Widget child;
  final Widget? hiddenChild;
  final bool show;
  final EdgeInsets? padding;
  final bool useCenter;

  const CrossFade({
    super.key,
    required this.child,
    this.hiddenChild,
    this.show = false,
    this.padding,
    this.useCenter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: AnimatedCrossFade(
        firstChild: hiddenChild ?? Container(),
        secondChild: childX(),
        duration: Duration(milliseconds: 300), // Slightly slower cross-fade
        crossFadeState: show
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
      ),
    );
  }

  Widget childX() {
    if (useCenter) return Center(child: child);
    return child;
  }
}
