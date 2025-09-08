import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/bottom_sheet_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

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
              title: Text('Choose from Gallery', style: AppStyles.bodyMedium),
              onTap: () async {
                RouteManager.pop();
                userAvatar = await pickGalleryImage();
                notifyListeners();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppPalettes.blackColor),
              title: Text('Take Photo', style: AppStyles.bodyMedium),
              onTap: () async {
                RouteManager.pop();
                userAvatar = await createCameraImage();
                notifyListeners();
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
