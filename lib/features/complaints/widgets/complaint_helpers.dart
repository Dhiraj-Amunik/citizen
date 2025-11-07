import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

class ComplaintHelper {
  ComplaintHelper._privateConstructor();

  static Color getStatusColor(String? status) {
    switch (status) {
      case "pending":
        return AppPalettes.liteOrangeColor;
      case "in-progress":
        return AppPalettes.yellowColor;
      case "resolved":
        return AppPalettes.liteGreyColor;

      default:
        return AppPalettes.liteRedColor;
    }
  }
}
