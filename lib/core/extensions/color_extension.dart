part of '../utils/app_palettes.dart';

extension ColorWithOpacity on Color {
  Color withOpacityExt(val) {
    return withValues(alpha: val);
  }
}
