import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';

class GeneralStream {
  GeneralStream._internal() {
    // Initialize with default locale immediately to avoid late initialization errors
    _locale = const Locale("en");
    _init();
  }

  static final GeneralStream _instance = GeneralStream._internal();

  static GeneralStream get instance => _instance;

  Locale _locale = const Locale("en");
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
      final oldLocale = _locale;
      _locale = Locale(code);
      
      // Clear translation cache when language changes for better performance
      if (oldLocale.languageCode != code) {
        await TranslationHelper.clearCache();
      }
      
      _languageStream.add(_locale);
    } catch (e) {
      throw Exception("Failed to set locale: $e");
    }
  }

  static void dispose() {
    _languageStream.close();
  }
}
