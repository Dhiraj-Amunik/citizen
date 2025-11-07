import 'dart:io';
import 'package:flutter/material.dart';
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
  final int maxFiles;
  
  const UploadMultiFilesWidget({
    super.key,
    required this.onTap,
    required this.onRemove,
    this.multipleFiles,
    this.title,
    this.maxFiles = 5,
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
              ? _buildUploadPlaceholder(context, localization, textTheme)
              : _buildFilesGrid(context),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context, dynamic localization, TextTheme textTheme) {
    return GestureDetector(
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
                text: localization.click_to_upload_doc_and_photo,
              ),
              TextSpan(text: "\n"),
              TextSpan(
                text: localization.maximum_5_are_allowed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilesGrid(BuildContext context) {
    return Wrap(
      spacing: Dimens.gapX2,
      runSpacing: Dimens.gapX2,
      alignment: WrapAlignment.spaceBetween,
      children: [
        ...List.generate(multipleFiles!.length, (index) {
          return _buildFileItem(context, index);
        }),
        if (multipleFiles!.length < maxFiles) 
          _buildAddMoreButton(context),
      ],
    ).allPadding(Dimens.paddingX4);
  }

  Widget _buildFileItem(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimens.radiusX2),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: 0.39.screenWidth,
            height: 0.3.screenWidth,
            child: _buildFilePreview(multipleFiles![index]),
          ),
          GestureDetector(
            onTap: () => onRemove(index),
            child: CircleAvatar(
              backgroundColor: AppPalettes.whiteColor,
              child: Icon(
                Icons.close,
                color: AppPalettes.blackColor,
                size: Dimens.scaleX2,
              ),
            ).allPadding(Dimens.paddingX3),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(File file) {
    String path = file.path.toLowerCase();
    
    if (path.endsWith('.pdf')) {
      return Container(
        color: AppPalettes.greyColor,
        child: Icon(Icons.picture_as_pdf, size: 40, color: AppPalettes.redColor),
      );
    } else if (path.endsWith('.doc') || path.endsWith('.docx')) {
      return Container(
        color: AppPalettes.greyColor,
        child: Icon(Icons.description, size: 40, color: AppPalettes.blueColor),
      );
    } else {
      // It's an image
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppPalettes.greyColor,
            child: Icon(Icons.broken_image, size: 40),
          );
        },
      );
    }
  }

  Widget _buildAddMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 0.39.screenWidth,
        height: 0.3.screenWidth,
        decoration: BoxDecoration(
          border: Border.all(color: AppPalettes.lightTextColor, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(Dimens.radiusX2),
        ),
        child: Icon(Icons.add, size: 40, color: AppPalettes.lightTextColor),
      ),
    );
  }
}