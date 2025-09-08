import 'dart:async';
import 'package:flutter/material.dart';

class GeneralStream {
  const GeneralStream._();

  static StreamController<Locale> languageStream = StreamController.broadcast();

  static void dispose() {
    languageStream.close();
  }
}
