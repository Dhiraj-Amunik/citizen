import 'package:flutter/material.dart';
import 'package:inldsevak/features/auth/models/request/validate_otp_request_model.dart';
import 'package:inldsevak/features/auth/view/user_register_view.dart';
import 'package:inldsevak/features/offline/view/offline_view.dart';
import 'package:inldsevak/features/offline/view_model/connectivty_provider.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/features/auth/view/login_view.dart';
import 'package:inldsevak/features/home/view/home_view.dart';
import 'package:inldsevak/splash_view.dart';
import 'package:provider/provider.dart';

class WrapperView extends StatelessWidget {
  const WrapperView({super.key});

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
          if (snapshot.hasError) {
            return LoginView();
          }

          return Consumer<ConnectivityProvider>(
            builder: (context, value, _) {
              if (!value.isOnline) {
                return OfflineView();
              }

              if (snapshot.data?.isRegistered == false) {
                if (snapshot.data?.number == null) {
                  return LoginView();
                }
                return UserRegisterView(
                  data: OtpRequestModel(phoneNo: snapshot.data!.number),
                );
              }
              if (snapshot.data?.isRegistered == true &&
                  snapshot.data?.token != null) {
                return HomeView();
              }
              return LoginView();
            },
          );
        },
      ),
    );
  }
}
