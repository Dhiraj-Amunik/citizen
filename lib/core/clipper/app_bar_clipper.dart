
import 'package:flutter/material.dart';

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top-left
    path.lineTo(0, 0);

    // Top-right
    path.lineTo(size.width, 0);

    // Bottom-right
    path.lineTo(
      size.width,
      size.height * 0.98,
    ); // Adjust this value to match your SVG

    // Create the curved dip at the bottom center (similar to SVG)
    path.cubicTo(
      size.width * 0.9,
      size.height, // First control point (right side)
      size.width * 0.1,
      size.height, // Second control point (left side)
      0,
      size.height * 0.97, // End point (bottom-left)
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
