import 'package:inldsevak/core/utils/app_fonts.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color accentColor = Color(0xFF4CAF50);

  static ThemeData lightTheme = ThemeData(
    fontFamily: AppFonts.poppins,
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: AppPalettes.whiteColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalettes.whiteColor,
      foregroundColor: AppPalettes.whiteColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppPalettes.blackColor),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    iconTheme: IconThemeData(color: AppPalettes.blackColor),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: AppPalettes.textFieldColor,
      hoverColor: AppPalettes.textFieldColor,
      fillColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.focused)
            ? AppPalettes.whiteColor
            : AppPalettes.textFieldColor;
      }),
      hintStyle: AppStyles.labelLarge,
    ),

    textTheme: TextTheme(
      displaySmall: AppStyles.displaySmall,
      displayMedium: AppStyles.displayMediumn,
      displayLarge: AppStyles.displayLarge,

      headlineSmall: AppStyles.headlineSmall,
      headlineMedium: AppStyles.headlineMedium,
      headlineLarge: AppStyles.headlineLarge,

      titleSmall: AppStyles.titleSmall,
      titleMedium: AppStyles.titleMedium,
      titleLarge: AppStyles.titleLarge,

      bodySmall: AppStyles.bodySmall,
      bodyMedium: AppStyles.bodyMedium,
      bodyLarge: AppStyles.bodyLarge,

      labelSmall: AppStyles.labelSmall,
      labelMedium: AppStyles.labelMedium,
      labelLarge: AppStyles.labelLarge,
    ),
  );
}
