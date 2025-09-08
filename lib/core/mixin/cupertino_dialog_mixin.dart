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
    return showCupertinoDialog(
      context: RouteManager.navigatorKey.currentState!.context,
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
            child: Text('Cancel', style: context.textTheme.labelMedium!),
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
    return showCupertinoDialog(
      context: RouteManager.navigatorKey.currentState!.context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(content, style: context.textTheme.titleSmall),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel', style: context.textTheme.labelLarge!),
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
