import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/bottom_sheet_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:quickalert/models/quickalert_type.dart';

class AvatarViewModel extends ChangeNotifier with BottomSheetMixin {
  File? userAvatar;

  Future<void> selectImage() async {
    try {
      showCustomBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppPalettes.blackColor),
              title: TranslatedText(
                text: 'Choose from Gallery',
                style: AppStyles.bodyMedium,
              ),
              onTap: () async {
                RouteManager.pop();
                userAvatar = await pickGalleryImage();
                notifyListeners();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppPalettes.blackColor),
              title: TranslatedText(
                text: 'Take Photo',
                style: AppStyles.bodyMedium,
              ),
              onTap: () async {
                RouteManager.pop();
                await Future.delayed(const Duration(milliseconds: 300));
                try {
                  final file = await createCameraImage();
                  if (file != null && await file.exists()) {
                    final fileSize = await file.length();
                    if (fileSize > 0) {
                      userAvatar = file;
                      notifyListeners();
                    } else {
                      CommonSnackbar(
                        text: "Image file is invalid. Please try again.",
                      ).showAnimatedDialog(type: QuickAlertType.error);
                    }
                  }
                }
                  catch (err, stackTrace) {
                  debugPrint("Error capturing image: $err");
                  debugPrint("Stack trace: $stackTrace");
                  CommonSnackbar(
                    text: "Failed to capture image. Please try again.",
                  ).showAnimatedDialog(type: QuickAlertType.error);
                }
              },
            ),
            SizeBox.sizeHX10
          ],
        ),
      );
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  void removeImage() {
    userAvatar = null;
    notifyListeners();
  }
}
