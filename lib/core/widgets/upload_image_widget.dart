import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/painters/dashed_border_painter.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class UploadImageWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String? title;
  final Function() onRemoveTap;
  final File? imageFile;
  const UploadImageWidget({
    super.key,
    required this.onTap,
    required this.onRemoveTap,
    this.title,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title ?? "${context.localizations.upload_photo} *",
          style: context.textTheme.bodySmall,
        ),
        SizeBox.sizeHX2,
        CustomPaint(
          painter: DashedBorderPainter(color: AppPalettes.lightTextColor),
          child: imageFile == null
              ? GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.all(Dimens.paddingX6),
                    width: double.infinity,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: context.textTheme.labelMedium,
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.file_upload_outlined,
                              size: Dimens.scaleX3B,
                            ).onlyPadding(bottom: Dimens.paddingX3),
                          ),
                          TextSpan(text: "\n"),
                          TextSpan(
                            style: context.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            text: context.localizations.click_to_upload_images,
                          ),
                          TextSpan(text: "\n"),
                          TextSpan(text: context.localizations.max_file_size),
                        ],
                      ),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.radiusX2),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(imageFile!, fit: BoxFit.cover),
                      GestureDetector(
                        onTap: onRemoveTap,
                        child: CircleAvatar(
                          backgroundColor: AppPalettes.whiteColor,
                          child: Icon(
                            Icons.close,
                            color: AppPalettes.blackColor,
                          ),
                        ).allPadding(Dimens.paddingX3),
                      ),
                    ],
                  ),
                ).allPadding(Dimens.widgetSpacing),
        ),
      ],
    );
  }
}
