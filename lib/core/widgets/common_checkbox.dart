import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class CommonCheckbox extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final bool isSelected;
  final bool showBorder;
  final bool showBackground;
  final Color borderColor;
  final Color backgroundColor;

  const CommonCheckbox({
    super.key,
    this.onTap,
    required this.title,
    this.isSelected = false,
    this.showBorder = true,
    this.showBackground = true,
    this.borderColor = AppPalettes.transparentColor,
    this.backgroundColor = AppPalettes.liteGreyColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: Dimens.scaleX2.spMax,
            height: Dimens.scaleX2.spMax,
            child: CustomPaint(
              painter: CheckboxPainter(
                borderRadius: Dimens.radiusX1,
                isSelected: isSelected,
                tickColor: AppPalettes.blackColor,
                tickWidth: 1.0,
                showBorder: showBorder,
                showBackground: showBackground,
                borderColor: borderColor,
                backgroundColor: backgroundColor,
              ),
            ),
          ),
          10.horizontalSpace,
          Flexible(child: Text(title, style: context.textTheme.labelMedium)),
        ],
      ),
    );
  }
}

class CheckboxPainter extends CustomPainter {
  final bool isSelected;
  final Color tickColor;
  final double tickWidth;
  final double borderRadius;
  final bool showBorder;
  final bool showBackground;
  final Color borderColor;
  final Color backgroundColor;

  CheckboxPainter({
    required this.isSelected,
    required this.tickColor,
    this.tickWidth = 1.0,
    required this.borderRadius,
    this.showBorder = true,
    this.showBackground = true,
    this.borderColor = Colors.cyan,
    this.backgroundColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showBackground) {
      final backgroundPaint = Paint()..color = backgroundColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        backgroundPaint,
      );
    }

    if (showBorder) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final rRect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rRect, borderPaint);
    }

    // Draw the tick if selected
    if (isSelected) {
      final tickPaint = Paint()
        ..color = tickColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = tickWidth
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.5)
        ..lineTo(size.width * 0.45, size.height * 0.7)
        ..lineTo(size.width * 0.75, size.height * 0.3);

      canvas.drawPath(path, tickPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is CheckboxPainter &&
        (oldDelegate.isSelected != isSelected ||
            oldDelegate.tickColor != tickColor ||
            oldDelegate.tickWidth != tickWidth ||
            oldDelegate.showBorder != showBorder ||
            oldDelegate.showBackground != showBackground ||
            oldDelegate.borderColor != borderColor ||
            oldDelegate.backgroundColor != backgroundColor);
  }
}
