import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
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
      msg: text ?? 'Please try again',
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
    ).then((_) {
      _isToastShowing = false;
    });
  }

  showAnimatedDialog({required QuickAlertType type, Function()? onTap}) async {
    if (_isDialogShowing) return;
    
    _isDialogShowing = true;
    final context = RouteManager.navigatorKey.currentState!.context;
    final localization = context.localizations;
    
    // Get localized title based on alert type
    String? title;
    switch (type) {
      case QuickAlertType.warning:
        title = localization.warning;
        break;
      case QuickAlertType.error:
        title = localization.error;
        break;
      case QuickAlertType.success:
        title = localization.success;
        break;
      case QuickAlertType.info:
        title = localization.info;
        break;
      default:
        title = null;
    }
    
    await QuickAlert.show(
      context: context,
      type: type,
      title: title,
      widget: TranslatedText(
        text: "$text",
        style: AppStyles.bodyMedium,
        textAlign: TextAlign.center,
      ),
      confirmBtnTextStyle: AppStyles.bodyMedium.copyWith(
        color: AppPalettes.whiteColor,
      ),
      onConfirmBtnTap: onTap,
      borderRadius: Dimens.radiusX2,
      confirmBtnText: localization.ok,
      confirmBtnColor: AppPalettes.primaryColor,
    ).then((_) {
      _isDialogShowing = false;
    });
  }
}