import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

class DashedBorderPainter extends CustomPainter {
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final double strokeWidth;

  DashedBorderPainter({
    this.radius = 8.0,
    this.dashWidth = 8.0,
    this.dashSpace = 4.0,
    this.color = AppPalettes.lightTextColor,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);

    double totalLength = path.computeMetrics().first.length;
    double currentLength = 0;

    while (currentLength < totalLength) {
      // Draw dash segment
      final PathMetric pathMetric = path.computeMetrics().first;
      final Path dashPath = pathMetric.extractPath(
        currentLength,
        currentLength + dashWidth,
      );
      canvas.drawPath(dashPath, paint);

      // Skip space between dashes
      currentLength += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}