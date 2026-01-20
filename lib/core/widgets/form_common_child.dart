import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:flutter/cupertino.dart';

class FormCommonChild<T> extends StatelessWidget {
  final String? heading;
  final Widget? headingWidget;
  final Widget child;
  final bool? isRequired;

  const FormCommonChild({
    super.key,
    this.heading,
    this.headingWidget,
    this.isRequired,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Dimens.gapX1,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headingWidget != null)
          Padding(
            padding: EdgeInsets.only(bottom: Dimens.gapX1),
            child: headingWidget,
          )
        else if (heading?.isNotEmpty == true)
          TranslatedText(
            text: "${heading!} ${isRequired == true ? '*' : ''}",
            style: context.textTheme.bodySmall,
          ).onlyPadding(bottom: Dimens.gapX1),
        child,
      ],
    );
  }
}
