import 'package:flutter/material.dart';
import 'package:inldsevak/features/offline/view/offline_view.dart';
import 'package:inldsevak/features/offline/view_model/connectivty_provider.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/features/auth/view/login_view.dart';
import 'package:inldsevak/features/home/view/home_view.dart';
import 'package:inldsevak/splash_view.dart';
import 'package:provider/provider.dart';

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
          return Consumer<ConnectivityProvider>(
            builder: (context, value, _) {
              if (!value.isOnline) {
                return OfflineView();
              }
              if (snapshot.data != null) {
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
