import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:quickalert/quickalert.dart';

class CommonSnackbar {
  String? text;
  static bool _isSnackbarShowing = false;
  static bool _isToastShowing = false;
  static bool _isDialogShowing = false;

  CommonSnackbar({this.text});
  
  void showSnackbar() {
    if (_isSnackbarShowing) return;
    
    _isSnackbarShowing = true;
    ScaffoldMessenger.of(
      RouteManager.navigatorKey.currentState!.context,
    ).showSnackBar(
      SnackBar(
        content: Text(text ?? ""), 
        duration: Duration(seconds: 5),
      ),
    ).closed.then((_) {
      _isSnackbarShowing = false;
    });
  }

  void showToast() {
    if (_isToastShowing) return;
    
    _isToastShowing = true;
    Fluttertoast.showToast(
      msg: text ?? 'Try again in some time',
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
      gravity: ToastGravity.BOTTOM,
    ).then((_) {
      _isToastShowing = false;
    });
  }

  showAnimatedDialog({required QuickAlertType type, Function()? onTap}) async {
    if (_isDialogShowing) return;
    
    _isDialogShowing = true;
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
      onConfirmBtnTap: onTap,
      borderRadius: Dimens.radiusX2,
      confirmBtnText: 'Ok',
      confirmBtnColor: AppPalettes.primaryColor,
    ).then((_) {
      _isDialogShowing = false;
    });
  }
}