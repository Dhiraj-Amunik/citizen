import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:flutter/material.dart';

/// Default App Button
class CommonButton extends StatefulWidget {
  final Function? onTap;
  final String? text;
  final double? width;
  final bool fullWidth;
  final Color? color;
  final Color? disabledColor;
  final Color? focusColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final ShapeBorder? shapeBorder;
  final Widget? child;
  final double? elevation;
  final double? height;
  final bool? enableScaleAnimation;
  final double? radius;
  final BorderRadius? onlyRadius;
  final bool isLoading;
  final bool isAnimationEnable;
  final bool isEnable;
  final Color? splashColor;
  final Color? textColor;
  final BorderSide? side;
  final double? fontSize;

  const CommonButton({
    this.onTap,
    this.text,
    this.width,
    this.color,
    this.fullWidth = true,
    this.padding,
    this.textStyle,
    this.textColor,
    this.shapeBorder,
    this.child,
    this.elevation,
    this.onlyRadius,
    this.isAnimationEnable = true,
    this.height,
    this.isEnable = true,
    this.disabledColor,
    this.focusColor,
    this.splashColor,
    this.enableScaleAnimation = true,
    this.radius,
    this.isLoading = false,
    this.side,
    super.key,
    this.fontSize,
  });

  @override
  _CommonButtonState createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  AnimationController? _controller;

  @override
  void initState() {
    if (widget.enableScaleAnimation.validate(value: widget.isAnimationEnable)) {
      _controller =
          AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: null ?? 50),
            lowerBound: 0.0,
            upperBound: 0.1,
          )..addListener(() {
            setState(() {});
          });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && widget.isAnimationEnable) {
      _scale = 1 - _controller!.value;
    }

    if (widget.enableScaleAnimation.validate(value: true)) {
      return Listener(
        onPointerDown: (details) {
          _controller?.forward();
        },
        onPointerUp: (details) {
          _controller?.reverse();
        },
        child: Transform.scale(scale: _scale, child: buildButton()),
      );
    } else {
      return buildButton();
    }
  }

  Widget buildButton() {
    return MaterialButton(
      minWidth: widget.fullWidth ? widget.width ?? double.infinity : null,
      elevation: widget.elevation ?? 2.0,
      height: widget.height ?? 55.height(),
      color: widget.color ?? AppPalettes.buttonColor,
      focusColor: widget.focusColor ?? AppPalettes.buttonColor,
      disabledColor:
          widget.disabledColor ?? AppPalettes.buttonColor.withOpacityExt(0.5),
      splashColor: widget.splashColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: const Duration(milliseconds: 300),
      padding:
          widget.padding ?? EdgeInsets.symmetric(horizontal: Dimens.paddingX10),
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius:
            widget.onlyRadius ??
            BorderRadius.circular(widget.radius ?? Dimens.radiusX2),
      ),
      onPressed: widget.isAnimationEnable || widget.isEnable
          ? widget.onTap as void Function()?
          : null,
      child: widget.isLoading
          ? SizedBox(
              height: 30.height(),
              width: 30.height(),
              child: CircularProgressIndicator(
                color: AppPalettes.whiteColor,
                strokeWidth: 2.height(),
              ),
            )
          : FittedBox(
              fit: BoxFit.fitHeight,
              child:
                  widget.child ??
                  Text(
                    widget.text ?? "",
                    style:
                        widget.textStyle ??
                        context.textTheme.bodyMedium?.copyWith(
                          color: widget.textColor ?? AppPalettes.whiteColor,
                          fontSize: widget.fontSize?.spMax,
                        ),
                  ),
            ),
    );
  }
}

// Boolean Extensions
extension BooleanExtensions on bool? {
  /// Validate given bool is not null and returns given value if null.
  bool validate({bool value = false}) => this ?? value;

  /// get int value from bool
  int getIntBool({bool value = false}) {
    if (this ?? value) {
      return 1;
    } else {
      return 0;
    }
  }
}
