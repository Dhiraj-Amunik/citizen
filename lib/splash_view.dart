import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 1.screenHeight,
        width: 1.screenWidth,
        child: Image.asset("assets/banners/splash.jpg", fit: BoxFit.cover),
      ),
    );
  }
}
