import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeWidget extends StatelessWidget {
  final double height;
  final String data;
  const QrCodeWidget({super.key, required this.height, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.height(),
      padding: EdgeInsets.all((height / 18).height()),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX2,
        border: Border.all(width: 0.8, color: AppPalettes.primaryColor),
        blurRadius: 4,
        spreadRadius: 2,
        shadowColor: AppPalettes.primaryColor.withOpacityExt(0.2),
      ),
      child: QrImageView(
        data: data,
        padding: const EdgeInsets.all(0),
        // embeddedImage: const AssetImage("assets/launcher_icon/logo_2.png"),
        // embeddedImageStyle: QrEmbeddedImageStyle(size: Size(30, 30)),
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
      ),
    );
  }
}
