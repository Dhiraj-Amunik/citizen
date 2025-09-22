import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/restart_app.dart';

class SessionController {
  SessionController._internal() {
    _init();
  }

  static final SessionController _instance = SessionController._internal();

  static SessionController get instance => _instance;

  static const _storage = FlutterSecureStorage();

  final StreamController<SecureModel?> _authController =
      StreamController<SecureModel?>.broadcast();

  SecureModel? _model;

  Future<void> _init() async {
    final token = await _storage.read(key: "token");
    final number = await _storage.read(key: "number");
    final isParty = await _storage.read(key: "isParty");
    final isRegistered = await _storage.read(key: "isRegistered");

    if (token != null && number != null) {
      _model = SecureModel(
        token: token,
        number: number,
        isPartyMemeber: isParty?.toLowerCase() == 'true' ? true : false,
        isRegistered: isRegistered?.toLowerCase() == 'true' ? true : false,
      );
    }
    await Future.delayed(Duration(seconds: 3));
    _authController.add(_model);
  }

  Future<void> setSession({required SecureModel data}) async {
    try {
      await Future.wait([
        _storage.write(key: "token", value: data.token),
        _storage.write(key: "number", value: data.number),
        _storage.write(
          key: "isParty",
          value: data.isPartyMemeber.toString().toLowerCase(),
        ),
        _storage.write(
          key: "isRegistered",
          value: data.isRegistered.toString().toLowerCase(),
        ),
      ]);
      _model = data;
      _authController.add(_model);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> setRegistered({required bool isRegistered}) async {
    try {
      await Future.wait([
        _storage.write(
          key: "isRegistered",
          value: isRegistered.toString().toLowerCase(),
        ),
      ]);
      _model?.isRegistered = isRegistered;
      _authController.add(_model);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> clearSession() async {
    _model = null;
    await Future.wait([
      _storage.delete(key: "token"),
      _storage.delete(key: "number"),
      _storage.delete(key: "isParty"),
      _storage.delete(key: "isRegistered"),
    ]);
    _authController.add(_model);
    if (RouteManager.navigatorKey.currentState!.canPop()) {
      RouteManager.popUntilHome();
    }
    RestartApp.restartApp();
  }

  Stream<SecureModel?> get userAuthChange => _authController.stream;

  Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  Future<bool> getRole() async {
    final isParty = await _storage.read(key: "isParty");
    return isParty?.toLowerCase() == 'true' ? true : false;
  }

  void dispose() {
    _authController.close();
  }
}

class SecureModel {
  String token;
  String number;
  bool? isPartyMemeber;
  bool? isRegistered;
  SecureModel({
    required this.token,
    required this.number,
    this.isPartyMemeber,
    this.isRegistered,
  });
}
