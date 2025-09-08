import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class ComplaintsWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String status;
  final String description;
  final String date;
  final Color color;
  const ComplaintsWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.description,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX2,
        spreadRadius: 2,
        blurRadius: 2,
      ),

      child: Column(
        spacing: Dimens.gapX2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: Dimens.gapX3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHelpers.buildIcons(path: icon, iconSize: Dimens.scaleX5),
              Expanded(child: Text(title, style: textTheme.bodySmall)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX3,
                  vertical: Dimens.paddingX,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radius100,
                  backgroundColor: color.withOpacityExt(0.2),
                ),
                child: Text(
                  status,
                  style: textTheme.labelMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
          Text(
            description,
            style: textTheme.labelMedium?.copyWith(
              color: AppPalettes.lightTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            spacing: Dimens.gapX2,
            children: [
              CommonHelpers.buildIcons(
                path: AppImages.calenderIcon,
                iconColor: context.iconsColor,
                iconSize: Dimens.scaleX2,
              ),
              Text("$date Aug, 2025", style: textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class ComplaintClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.6, 50);
    path.lineTo(size.width, 50);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

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
