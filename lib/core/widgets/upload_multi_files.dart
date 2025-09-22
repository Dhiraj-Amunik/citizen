import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/painters/dashed_border_painter.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class UploadMultiFilesWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String? title;
  final Function(int index) onRemove;
  final List<File>? multipleFiles;
  const UploadMultiFilesWidget({
    super.key,
    required this.onTap,
    required this.onRemove,
    this.multipleFiles,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title ?? localization.upload_photos, style: textTheme.bodySmall),
        SizeBox.sizeHX2,
        CustomPaint(
          painter: DashedBorderPainter(color: AppPalettes.lightTextColor),
          child: multipleFiles?.isEmpty == true
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
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            text: context
                                .localizations
                                .click_to_upload_doc_and_photo,
                          ),
                          TextSpan(text: "\n"),
                          TextSpan(
                            text: context.localizations.maximum_5_are_allowed,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: Dimens.gapX2,
                  runSpacing: Dimens.gapX2,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    ...List.generate(multipleFiles!.length, (index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.radiusX2),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: 0.39.screenWidth,
                              height: 0.3.screenWidth,
                              child: Image.file(
                                multipleFiles![index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => onRemove(index),
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
                      );
                    }),
                  ],
                ).allPadding(Dimens.paddingX4),
        ),
      ],
    );
  }
}
