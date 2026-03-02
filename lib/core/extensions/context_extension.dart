import 'package:flutter/material.dart';
import 'package:inldsevak/l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  /// Optimized localization accessor
  /// Flutter's Localizations.of already caches efficiently, but we ensure
  /// proper error handling for better performance in Hindi locale
  AppLocalizations get localizations {
    final loc = AppLocalizations.of(this);
    if (loc == null) {
      throw FlutterError(
        'AppLocalizations not found. Make sure your app is wrapped with '
        'MaterialApp or Localizations widget with AppLocalizations.delegate.',
      );
    }
    return loc;
  }

  ThemeData get theme => Theme.of(this);
  Color get cardColor => theme.cardColor;
  Color get primaryColor => theme.primaryColor;
  Color get iconsColor => theme.iconTheme.color!;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  TextTheme get textTheme => theme.textTheme;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get screenWidth => MediaQuery.sizeOf(this).width;
}
