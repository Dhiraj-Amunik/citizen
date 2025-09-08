import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:quickalert/quickalert.dart';

class CommonSnackbar {
  String? text;
  CommonSnackbar({this.text});
  void showSnackbar() {
    ScaffoldMessenger.of(
      RouteManager.navigatorKey.currentState!.context,
    ).showSnackBar(
      SnackBar(content: Text(text ?? ""), duration: Duration(seconds: 5)),
    );
  }

  void showToast() {
    Fluttertoast.showToast(
      msg: text ?? 'Try again in some time',
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
      gravity: ToastGravity.BOTTOM,
    );
  }

  showAnimatedDialog({required QuickAlertType type}) async {
    await QuickAlert.show(
      context: RouteManager.navigatorKey.currentState!.context,
      type: type,
      widget: Text(
        "$text",
        style: AppStyles.bodyMedium,
        textAlign: TextAlign.center,
      ),
      confirmBtnTextStyle: AppStyles.bodyMedium.copyWith(
        color: AppPalettes.whiteColor,
      ),
      borderRadius: Dimens.radiusX2,
      confirmBtnText: 'Ok',
      confirmBtnColor: AppPalettes.primaryColor,
    );
  }
}
