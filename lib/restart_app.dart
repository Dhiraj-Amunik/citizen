import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';

class RestartApp extends StatefulWidget {
  final Widget child;

  const RestartApp({super.key, required this.child});

  static void restartApp() {
    RouteManager.navigatorKey.currentState!.context
        .findAncestorStateOfType<_RestartWidgetState>()
        ?.restartApp();
  }

  @override
  State<RestartApp> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
