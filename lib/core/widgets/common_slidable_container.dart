import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';

class CommonSlidableContainer extends StatelessWidget {
  final Widget child;
  final List<Widget> actions;
  final bool isEnable;
  final double extendRatio;

  const CommonSlidableContainer({
    super.key,
    required this.child,
    this.isEnable = true,
    required this.actions,
    required this.extendRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: isEnable,
      endActionPane: ActionPane(
        extentRatio: extendRatio,
        motion: const ScrollMotion(),
        children: actions,
      ),
      child: child,
    );
  }
}

class ActionButton {
  static Widget getButtons({
    required Function()? onTap,
    required Size size,
    Color? color,
    double? borderRadius,
    required String svgIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius ?? 0.0),
        ),
        child: SvgPicture.asset(svgIcon, fit: BoxFit.scaleDown),
      ),
    );
  }
}
