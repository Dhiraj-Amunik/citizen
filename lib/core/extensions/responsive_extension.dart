import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ResponsiveExtensions on num {

  double get screenWidth => (this).sw;
  double get screenHeight => (this).sh;

  double width() => (this).w;
  double height() => (this).h;
}
