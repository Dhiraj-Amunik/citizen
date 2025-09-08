import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/routes/routes.dart';

class Dimens {
  Dimens._privateConstructor();

  //padding
  static const padding = 0.0;
  static final paddingX = 2.0.r;
  static final paddingX1 = 4.0.r;
  static final paddingX1B = 6.0.r;
  static final paddingX2 = 8.0.r;
  static final paddingX2B = 10.0.r;
  static final paddingX3 = 12.0.r;
  static final paddingX3B = 14.0.r;
  static final paddingX4 = 16.0.r;
  static final paddingX4B = 18.0.r;
  static final paddingX5 = 20.0.r;
  static final paddingX6 = 24.0.r;
  static final paddingX7 = 28.0.r;
  static final paddingX8 = 32.0.r;
  static final paddingX9 = 36.0.r;
  static final paddingX10 = 40.0.r;

  //margin
  static const margin = 0.0;
  static final marginX2 = 8.0.r;
  static final marginX1 = 4.0.r;
  static final marginX3 = 12.0.r;
  static final marginX4 = 16.0.r;
  static final marginX5 = 20.0.r;
  static final marginX6 = 24.0.r;
  static final marginX7 = 28.0.r;
  static final marginX8 = 32.0.r;

  //radius
  static const radius = 0.0;
  static final radiusX1 = 4.0.r;
  static final radiusX2 = 8.0.r;
  static final radiusX3 = 12.0.r;
  static final radiusX4 = 16.0.r;
  static final radiusX5 = 20.0.r;
  static final radiusX6 = 24.0.r;
  static final radiusX7 = 28.0.r;
  static final radiusX10 = 40.0.r;
  static const radius100 = 100.0;

  //standard scales
  static final scale = 0.0;
  static final scaleX = 4.0.r;
  static final scaleX1 = 8.0.r;
  static final scaleX1B = 14.0.r;
  static final scaleX2 = 16.0.r;
  static final scaleX2B = 20.0.r;
  static final scaleX3 = 24.0.r;
  static final scaleX3B = 28.0.r;
  static final scaleX4 = 32.0.r;
  static final scaleX5 = 40.0.r;
  static final scaleX6 = 48.0.r;
  static final scaleX7 = 56.0.r;
  static final scaleX8 = 64.0.r;
  static final scaleX9 = 72.0.r;
  static final scaleX10 = 80.0.r;
  static final scaleX15 = 120.0.r;

  //dividers
  static const gap = 0.0;
  static final gapX = 2.0.r;
  static final gapX1 = 4.0.r;
  static final gapX1B = 6.0.r;
  static final gapX2 = 8.0.r;
  static final gapX3 = 12.0.r;
  static final gapX4 = 16.0.r;
  static final gapX5 = 20.0.r;
  static final gapX6 = 24.0.r;
  static final gapX7 = 28.0.r;
  static final gapX8 = 32.0.r;
  static final gapX9 = 36.0.r;
  static final gapX10 = 40.0.r;

  static final screenWidth = 1.sw;
  static final screenHalfWidth = 0.5.sw;
  static final screenHeight = 1.sh;
  static final screenHAlfHeight = 0.5.sh;

  static final textFromSpacing = 16.r;
  static final widgetSpacing = 18.r;
  static final horizontalspacing = 22.r;
  static final verticalspacing = 22.r;

  static final borderWidth = 1.w;

  static const elevation = 2.0;
  static final appBarSpacing = 10.r;

  static final statusBarHeight = MediaQuery.viewPaddingOf(
    RouteManager.navigatorKey.currentState!.context,
  ).top;
}
