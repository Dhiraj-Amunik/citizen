import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/navigation/model/navigation_model.dart';

class TabIconWidget extends StatefulWidget {
  final NavigationModel data;
  final VoidCallback onTap;
  final bool isSelected;
  const TabIconWidget({
    super.key,
    required this.data,
    required this.onTap,
    required this.isSelected,
  });

  @override
  State<TabIconWidget> createState() => _TabIconWidgetState();
}

class _TabIconWidgetState extends State<TabIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> colorAnimation;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    colorAnimation =
        ColorTween(
          begin: widget.isSelected
              ? AppPalettes.transparentColor
              : AppPalettes.primaryColor,
          end: widget.isSelected
              ? AppPalettes.primaryColor
              : AppPalettes.transparentColor,
        ).animate(_controller)..addListener(() {
          setState(() {});
        });

    if (widget.isSelected) {
      _controller.forward();
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
        ),
        decoration: widget.isSelected
            ? boxDecorationRoundedWithShadow(
                Dimens.radius100,
                backgroundColor:
                    colorAnimation.value ?? AppPalettes.primaryColor,
              )
            : null,
        child: Row(
          spacing: Dimens.gapX2,
          children: [
            if (widget.data.imagePath != null &&
                widget.data.imagePath!.endsWith("png"))
              Image.asset(widget.data.imagePath!, height: Dimens.scaleX3B),
            if (widget.data.imagePath != null &&
                widget.data.imagePath!.endsWith("svg"))
              SvgPicture.asset(
                widget.data.imagePath!,
                height: Dimens.scaleX2B,
                width: Dimens.scaleX2B,
                colorFilter: ColorFilter.mode(
                  widget.isSelected
                      ? AppPalettes.whiteColor
                      : AppPalettes.blackColor,
                  BlendMode.srcIn,
                ),
              ),
            if (widget.isSelected)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TranslatedText(
                  text: widget.data.text!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: widget.isSelected
                        ? AppPalettes.whiteColor
                        : AppPalettes.transparentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}



/*
 Container(
        padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing:
              (data.imagePath != null && data.imagePath!.endsWith("png")) ==
                  true
              ? Dimens.gapX1
              : Dimens.gapX2,
          children: [
            if (data.imagePath != null && data.imagePath!.endsWith("png"))
              Image.asset(
                data.imagePath!,
                height: Dimens.scaleX3B,
              ),
            if (data.imagePath != null && data.imagePath!.endsWith("svg"))
              SvgPicture.asset(
                data.imagePath!,
                height: Dimens.scaleX2B,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? AppPalettes.primaryColor
                      : AppPalettes.blackColor,
                  BlendMode.srcIn,
                ),
              ),
            Text(
              data.text!,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppPalettes.primaryColor
                    : AppPalettes.blackColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
 
*/