import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralStream {
  GeneralStream._internal() {
    _init();
  }

  static final GeneralStream _instance = GeneralStream._internal();

  static GeneralStream get instance => _instance;

  late Locale _locale;
  Locale get locale => _locale;

  static final StreamController<Locale> _languageStream =
      StreamController.broadcast();
  Stream<Locale> get language => _languageStream.stream;

  Future<void> _init() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String code = sp.getString("language_code") ?? "en";
      _locale = Locale(code);
    } catch (e) {
      _locale = const Locale("en");
    } finally {
      _languageStream.add(_locale);
    }
  }

   Future<void> setLocale(String code) async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setString("language_code", code);
      _locale = Locale(code);
      _languageStream.add(_locale);
    } catch (e) {
      throw Exception("Failed to set locale: $e");
    }
  }

  static void dispose() {
    _languageStream.close();
  }
}
