import 'package:flutter/material.dart';
import 'package:inldsevak/l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
  ThemeData get theme => Theme.of(this);
  Color get cardColor => theme.cardColor;
  Color get primaryColor => theme.primaryColor;
  Color get iconsColor => theme.iconTheme.color!;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  TextTheme get textTheme => theme.textTheme;
}
