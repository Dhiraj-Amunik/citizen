import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

mixin SingleImagePickerMixin {
  Future<File?> showSingleImageSheet({bool isImage = false}) {
    return showModalBottomSheet<File?>(
      backgroundColor: AppPalettes.whiteColor,
      useSafeArea: true,
      isScrollControlled: true,
      context: RouteManager.navigatorKey.currentState!.context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          margin: EdgeInsets.all(Dimens.paddingX5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppPalettes.blackColor,
                ),
                title: TranslatedText(
                  text: 'Choose from Gallery',
                  style: AppStyles.bodyMedium,
                ),
                onTap: () async {
                  File? file = await pickGalleryImage();
                  RouteManager.pop(file);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppPalettes.blackColor),
                title: TranslatedText(
                  text: 'Take Photo',
                  style: AppStyles.bodyMedium,
                ),
                onTap: () async {
                  File? file = await createCameraImage();
                  RouteManager.pop(file);
                },
              ),

              ListTile(
                leading: Icon(Icons.camera_alt, color: AppPalettes.blackColor),
                title: TranslatedText(
                  text: 'Choose from Files',
                  style: AppStyles.bodyMedium,
                ),
                onTap: () async {
                  File? file = await pickSingleFile(isImage: isImage);
                  RouteManager.pop(file);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
