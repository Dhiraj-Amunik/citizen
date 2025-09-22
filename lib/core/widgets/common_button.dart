import 'dart:math';

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
  final Color? borderColor;
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
    this.borderColor,
    this.side,
    super.key,
    this.fontSize,
  });

  @override
  _CommonButtonState createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton>
    with TickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _gradientController;
  late AnimationController _controller;

  @override
  void initState() {
    if (widget.enableScaleAnimation.validate(value: widget.isAnimationEnable)) {
      _gradientController =
          AnimationController(vsync: this, duration: Duration(seconds: 6))
            ..forward()
            ..repeat();

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
    _controller.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAnimationEnable) {
      _scale = 1 - _controller.value;
    }

    if (widget.enableScaleAnimation.validate(value: true)) {
      return Listener(
        onPointerDown: (details) {
          _controller.forward();
        },
        onPointerUp: (details) {
          _controller.reverse();
        },
        child: Transform.scale(scale: _scale, child: buildButton()),
      );
    } else {
      return buildButton();
    }
  }

  Widget buildButton() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, _) {
        return InkWell(
          onTap: widget.isAnimationEnable || widget.isEnable
              ? widget.onTap as void Function()?
              : null,
          overlayColor: WidgetStatePropertyAll(AppPalettes.transparentColor),
          child: Container(
            width: widget.fullWidth ? widget.width ?? double.infinity : null,
            height: widget.height ?? 50.height(),
            padding:
                widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX10,
                  vertical: Dimens.paddingX2B,
                ),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius:
                  widget.onlyRadius ??
                  BorderRadius.circular(widget.radius ?? Dimens.radiusX4),
              border: Border.all(
                color:
                    widget.borderColor ??
                    AppPalettes.whiteColor.withOpacityExt(0.2),
                width: 1.4,
              ),
              gradient: widget.color == null
                  ? LinearGradient(
                      colors: [
                        AppPalettes.gradientFirstColor,
                        AppPalettes.gradientSecondColor,
                      ],
                      transform: GradientRotation(
                        _gradientController.value * 2 * pi,
                      ),
                    )
                  : null,
              //  boxShadow: [
              //   BoxShadow(
              //     color: AppPalettes.gradientSecondColor.withOpacityExt(0.4),
              //     blurRadius: 2,
              //     spreadRadius:1,
              //     offset: Offset.fromDirection(
              //       _gradientController.value * 2 * pi,
              //       3.5,
              //     ),
              //   ),
              //   BoxShadow(
              //     color: AppPalettes.gradientFirstColor.withOpacityExt(0.4),
              //     blurRadius: 2,
              //     spreadRadius: 1,
              //     offset: Offset.fromDirection(
              //       _gradientController.value + 0.5 * 2 * pi,
              //       3.5,
              //     ),
              //   ),
              // ],
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: widget.isLoading
                  ? CircularProgressIndicator(
                      color: AppPalettes.whiteColor,
                      strokeWidth: 2.height(),
                    )
                  : widget.child ??
                        Text(
                          widget.text ?? "",
                          style:
                              widget.textStyle ??
                              context.textTheme.bodyLarge?.copyWith(
                                color:
                                    widget.textColor ?? AppPalettes.whiteColor,
                                fontSize: widget.fontSize?.spMax,
                              ),
                        ),
            ),
          ),
        );
      },
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

/*

   
*/
