import 'package:flutter/material.dart';

/// A widget that dismisses the keyboard when tapping outside of text fields
class DismissKeyboardWidget extends StatelessWidget {
  const DismissKeyboardWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

