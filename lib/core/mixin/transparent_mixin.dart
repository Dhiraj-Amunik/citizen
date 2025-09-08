import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

mixin TransparentCircular {
  showCustomDialogTransperent({required bool isShowing}) {
    isShowing
        ? showDialog(
            barrierDismissible: false,
            context: RouteManager.navigatorKey.currentState!.context,
            builder: (_) => PopScope(
              canPop: true,
              child: Dialog(
                elevation: 0,
                backgroundColor: const Color(0x00ffffff),
                child: Container(
                  color: const Color(0x00ffffff),
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 55.0),
                  child: CircularProgressIndicator(
                    color: AppPalettes.primaryColor,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          )
        : RouteManager.pop();
  }
}
