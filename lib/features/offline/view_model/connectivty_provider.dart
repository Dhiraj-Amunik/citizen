import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result.first == ConnectivityResult.none) {
        CommonSnackbar(text: "Please connect to internet").showToast();
        isOnline = false;
      } else {
        isOnline = true;
      }
    });
  }

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  set isOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  late StreamSubscription subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
