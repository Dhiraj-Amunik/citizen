import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class DraggableSheetWidget extends StatefulWidget {
  final Widget child;
  final Widget? bottomChild;
  final Color? backgroundColor;
  final Color? indicatorcolor;
  final double size;
  final bool showClose;
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
    this.showClose = false,
  });

  @override
  State<DraggableSheetWidget> createState() => _DraggableSheetWidgetState();
}

class _DraggableSheetWidgetState extends State<DraggableSheetWidget> {
  @override
  void initState() {
    super.initState();
    // controller.addListener(collapse);
  }

  void onChange() {
    final currentSize = controller.size;
    if (currentSize <= 0.05) collapse();
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);
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
          maxChildSize: 0.7,
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
                  if (widget.showClose==false)
                    topButtonIndicitor(widget.indicatorcolor),
                  if (widget.showClose == true)
                    topCloseIndicitor(widget.indicatorcolor),
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

  SliverToBoxAdapter topCloseIndicitor(Color? color) {
    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => RouteManager.pop(),
            child: Container(
              padding: EdgeInsets.all(Dimens.paddingX2),
              margin: EdgeInsets.only(
                top: Dimens.marginX6,
                right: Dimens.marginX6,
              ),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radius100,
                backgroundColor: AppPalettes.primaryColor,
              ),
              child: Icon(Icons.close_rounded, color: AppPalettes.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter topButtonIndicitor(Color? color) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: Dimens.marginX6,bottom: Dimens.marginX4),
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
