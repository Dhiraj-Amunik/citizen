import 'package:flutter/material.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/features/auth/models/request/validate_otp_request_model.dart';
import 'package:inldsevak/features/auth/view/login_view.dart';
import 'package:inldsevak/features/auth/view/user_register_view.dart';
import 'package:inldsevak/features/home/view/home_view.dart';
import 'package:inldsevak/splash_view.dart';

class WrapperView extends StatefulWidget {
  const WrapperView({super.key});

  @override
  State<WrapperView> createState() => _WrapperViewState();
}

class _WrapperViewState extends State<WrapperView> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: StreamBuilder<SecureModel?>(
        stream: SessionController.instance.userAuthChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashView();
          }
          if (snapshot.data != null) {
            return UserRegisterView(data: OtpRequestModel(phoneNo: "9789876545"),);
          }
          return LoginView();
        },
      ),
    );
  }
}
