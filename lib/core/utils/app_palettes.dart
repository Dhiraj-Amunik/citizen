import 'package:flutter/material.dart';

part '../extensions/color_extension.dart';

class AppPalettes {
  AppPalettes._privateConstructor();
  static AppPalettes? of(BuildContext context) {
    return Localizations.of<AppPalettes>(context, AppPalettes);
  }

  static const primaryColor = Color(0xFF2B7730);
  static const secondaryColor = Color(0xffE5FBFF);
  static const liteGreyColor = Color(0xffF3F4F4);
  static const greyColor = Color(0xffB0B0B0);
  static const shadowColor = Color.fromARGB(255, 255, 255, 255);
  static const blackColor = Color(0xff000000);
  static const lightTextColor = Color(0xff6A6971);
  static const Color redColor = Color(0xFFdc3a31);
  static const Color transparentColor = Colors.transparent;
  static const dividerColor = Color(0xffDCDBDD);
  static const iconBackgroundColor = Color(0xffFCF8FF);

  static const borderColor = Color(0xffB4B4B8);
  static const whiteColor = Color(0xFFFFFFFF);
  static const buttonColor = Color(0xFF2B7730);
  static const textFieldColor = Color(0xFFF6F6F6);
  static const backGroundColor = Color.fromARGB(255, 245, 243, 243);
  static const iconColor = Color(0xff6A6971);

  static const greenColor = Color(0xFF4DC855);

  static const gradientFirstColor = Color(0xFF27AE60);
  static const gradientSecondColor = Color(0xFF4DC855);

  static const blueColor = Color(0xFF1E3A8A);
  static const yellowColor = Color(0xFFFFB700);

  static const ratingColor = Color(0xFFFCC21B);
}
