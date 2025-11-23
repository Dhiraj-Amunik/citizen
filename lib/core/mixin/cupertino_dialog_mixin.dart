import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';

mixin CupertinoDialogMixin {
  Future<void> customLeftCupertinoDialog({
    required String content,
    required String leftButton,
    Function()? onTap,
  }) {
    final context = RouteManager.navigatorKey.currentState!.context;
    final localization = context.localizations;
    
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(content, style: context.textTheme.titleSmall),
        actions: [
          CupertinoDialogAction(
            onPressed: onTap,
            child: Text(
              leftButton,
              style: context.textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          CupertinoDialogAction(
            child: Text(localization.cancel, style: context.textTheme.labelMedium!),
            onPressed: () {
              RouteManager.pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> customRightCupertinoDialog({
    required String content,
    required String rightButton,
    Function()? onTap,
  }) {
    final context = RouteManager.navigatorKey.currentState!.context;
    final localization = context.localizations;
    
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(content, style: context.textTheme.titleSmall),
        actions: [
          CupertinoDialogAction(
            child: Text(localization.cancel, style: context.textTheme.labelLarge!),
            onPressed: () {
              RouteManager.pop();
            },
          ),
          CupertinoDialogAction(
            onPressed: onTap,
            child: Text(
              rightButton,
              style: context.textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
