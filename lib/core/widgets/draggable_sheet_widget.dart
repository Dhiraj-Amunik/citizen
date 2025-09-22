import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class DraggableSheetWidget extends StatefulWidget {
  final Widget child;
  final Widget? bottomChild;
  final Color? backgroundColor;
  final Color? indicatorcolor;
  final double size;
  final double radius;
  final Function()? onCompleted;
  const DraggableSheetWidget({
    super.key,
    required this.child,
    this.bottomChild,
    this.backgroundColor,
    this.indicatorcolor,
    required this.size,
    this.radius = Dimens.radius100,
    this.onCompleted,
  });

  @override
  State<DraggableSheetWidget> createState() => _DraggableSheetWidgetState();
}

class _DraggableSheetWidgetState extends State<DraggableSheetWidget> {
  @override
  void initState() {
    super.initState();
    controller.addListener(onChange);
    controller.addListener(collapse);
  }

  void onChange() {
    final currentSize = controller.size;
    if (currentSize <= 0.05) collapse();
  }

  void collapse() => animateCompleteSheet(getSheet.snapSizes!.first);
  void anchor() => animateSheet(getSheet.snapSizes!.last);
  void expand() => animateSheet(getSheet.maxChildSize);
  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double size) {
    controller.animateTo(
      size,
      duration: const Duration(microseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  void animateCompleteSheet(double size) {
    controller.animateTo(
      size,
      duration: const Duration(microseconds: 50),
      curve: Curves.easeInOut,
    );
    widget.onCompleted;
  }

  DraggableScrollableSheet get getSheet =>
      (sheet.currentWidget as DraggableScrollableSheet);
  final sheet = GlobalKey();
  final controller = DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (builder, constraints) {
        return DraggableScrollableSheet(
          controller: controller,
          key: sheet,
          initialChildSize: widget.size,
          maxChildSize: 0.8,
          minChildSize: 0,
          expand: false,
          snap: true,
          snapSizes: [0 / constraints.maxHeight, widget.size],
          builder: (context, scrollController) {
            return DecoratedBox(
              decoration: boxDecorationRoundedWithShadow(
                widget.radius,
                disableBottomRadius: true,
                backgroundColor:
                    widget.backgroundColor ?? AppPalettes.whiteColor,
              ),
              child: CustomScrollView(
                shrinkWrap: true,
                controller: scrollController,

                slivers: [
                  topButtonIndicitor(widget.indicatorcolor),
                  SliverToBoxAdapter(child: widget.child),
                  SliverToBoxAdapter(child: SizeBox.sizeHX4),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: widget.bottomChild,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  SliverToBoxAdapter topButtonIndicitor(Color? color) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: Dimens.marginX4),
          height: Dimens.scaleX,
          width: Dimens.scaleX7,
          decoration: boxDecorationRoundedWithShadow(
            widget.radius,
            backgroundColor: color ?? AppPalettes.iconColor,
          ),
        ),
      ),
    );
  }
}
