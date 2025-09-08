import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/dio/api_status_enum.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';

class BaseViewModel extends ChangeNotifier {
  late SessionController controller;
  BaseViewModel() {
    initialize();
  }

  initialize() async {
    controller = SessionController.instance;
    await getToken();
    await onInit();
  }

  Future<void> onInit() async {}

  ApiStatus _status = ApiStatus.none;

  ApiStatus get status => _status;

  void setApiStatus(ApiStatus value) {
    _status = value;
    notifyListeners();
  }

  bool _isLoading = false;
  String? _token;
  bool? _role;
  String? get token => _token;
  bool? get role => _role;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> setSecureStorage({
    required String setToken,
    required String phonenumber,
    required bool isPartyMember,
  }) async {
    log(setToken);
    await controller.setSession(
      data: SecureModel(
        token: setToken,
        number: phonenumber,
        isPartyMemeber: isPartyMember,
      ),
    );
  }

  Future<void> getToken() async {
    _token = await controller.getToken();
  }

  Future<void> getRole() async {
    _role = await controller.getRole();
  }

  Future<void> clearToken() async {
    controller.clearSession();
  }
}
