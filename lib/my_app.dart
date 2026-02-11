import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/provider/providers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_theme.dart';
import 'package:inldsevak/l10n/localizations_exports.dart';
import 'package:inldsevak/notification_service.dart';
import 'package:inldsevak/restart_app.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _currentLocale;
  StreamSubscription<Locale>? _localeSubscription;

  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer to detect when app resumes
    WidgetsBinding.instance.addObserver(this);

    // Initialize locale synchronously (now safe since GeneralStream has default value)
    _currentLocale = GeneralStream.instance.locale;

    // Listen to locale changes and update only when needed
    _localeSubscription = GeneralStream.instance.language.listen((locale) {
      if (mounted && _currentLocale != locale) {
        setState(() {
          _currentLocale = locale;
        });
      }
    });

    KeyboardVisibilityController().onChange.listen((isVisible) {
      if (!isVisible) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app resumes from background/terminated, check if we need to refresh data
    // This is where we safely call APIs (not in background handler)
    if (state == AppLifecycleState.resumed) {
      // Use a small delay to ensure app is fully resumed and providers are ready
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          NotificationService.checkAndRefreshDataIfNeeded();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(384.0, 832.0),
      minTextAdapt: true,
      ensureScreenSize: false,
      splitScreenMode: true,

      builder: (_, _) {
        return RestartApp(
          child: MultiProvider(
            providers: AppProviders.provider,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              supportedLocales: L10n.locals,
              locale: _currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.lightTheme,
              initialRoute: Routes.wrapperPage.path,
              navigatorKey: RouteManager.navigatorKey,
              onGenerateRoute: RouteManager.onGenerateRoute,
            ),
          ),
        );
      },
    );
  }
}
