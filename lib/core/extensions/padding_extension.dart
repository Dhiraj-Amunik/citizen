import 'package:flutter/material.dart';

extension PaddingExtensions on Widget? {
  Widget horizontalPadding(double padding) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: padding), child: this);
  Widget allPadding(double padding) =>
      Padding(padding: EdgeInsets.all(padding), child: this);
  Widget verticalPadding(double padding) =>
      Padding(padding: EdgeInsets.symmetric(vertical: padding), child: this);

  Widget symmetricPadding({double? vertical, double? horizontal}) => Padding(
      padding: EdgeInsets.symmetric(
          vertical: vertical ?? 0.0, horizontal: horizontal ?? 0.0),
      child: this);
  Widget onlyPadding({
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) =>
      Padding(
          padding: EdgeInsets.only(
              left: left ?? 0.0,
              right: right ?? 0.0,
              top: top ?? 0.0,
              bottom: bottom ?? 0.0),
          child: this);
}
