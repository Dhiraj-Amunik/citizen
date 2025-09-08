import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

mixin BottomSheetMixin {
  Future<void> showCustomBottomSheet({required Widget child, double? height}) {
    return showModalBottomSheet(
      backgroundColor: AppPalettes.whiteColor,
      useSafeArea: true,
      isScrollControlled: true,
      context: RouteManager.navigatorKey.currentState!.context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: height,
          margin: const EdgeInsets.all(20).copyWith(bottom: 0),
          child: child,
        ),
      ),
    );
  }
}
