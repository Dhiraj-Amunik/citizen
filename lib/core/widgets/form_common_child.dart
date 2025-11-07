import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:flutter/cupertino.dart';

class FormCommonChild<T> extends StatelessWidget {
  final String? heading;
  final Widget child;
  final bool? isRequired;

  const FormCommonChild({
    super.key,
    this.heading,
    this.isRequired,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Dimens.gapX1,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading?.isNotEmpty == true)
          Text(
            "${heading!} ${isRequired == true ? '*' : ''}",
            style: context.textTheme.bodySmall,
          ).onlyPadding(bottom: Dimens.gapX1),
        child,
      ],
    );
  }
}
