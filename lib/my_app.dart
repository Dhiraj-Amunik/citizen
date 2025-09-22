import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/provider/providers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_theme.dart';
import 'package:inldsevak/l10n/localizations_exports.dart';
import 'package:inldsevak/restart_app.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(384.0, 832.0),
      minTextAdapt: true,
      ensureScreenSize: true,
      splitScreenMode: true,
      builder: (_, _) {
        return StreamBuilder<Locale>(
          stream: GeneralStream.instance.language,
          builder: (context, snapshot) {
            return RestartApp(
              child: MultiProvider(
                providers: AppProviders.provider,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  supportedLocales: L10n.locals,
                  locale: snapshot.data,
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
      },
    );
  }
}
