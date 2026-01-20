import 'dart:async';
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
    debugPrint("🟣 [showSingleImageSheet] Called - isImage: $isImage");
    final Completer<File?> completer = Completer<File?>();
    // Track if user selected an option to prevent race condition
    bool optionSelected = false;
    
    showModalBottomSheet<File?>(
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
                  debugPrint("🟣 [showSingleImageSheet] Gallery option tapped");
                  optionSelected = true;
                  RouteManager.pop();
                  File? file = await pickGalleryImage();
                  debugPrint("🟣 [showSingleImageSheet] Gallery file picked: ${file?.path}");
                  if (!completer.isCompleted) {
                    completer.complete(file);
                    debugPrint("🟣 [showSingleImageSheet] Completer completed with gallery file");
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppPalettes.blackColor),
                title: TranslatedText(
                  text: 'Take Photo',
                  style: AppStyles.bodyMedium,
                ),
                onTap: () async {
                  debugPrint("🟣 [showSingleImageSheet] Camera option tapped");
                  optionSelected = true;
                  // Close bottom sheet first
                  RouteManager.pop();
                  // Add longer delay for older devices to ensure bottom sheet is fully closed
                  // This prevents crashes on older devices when camera is accessed immediately
                  await Future.delayed(const Duration(milliseconds: 600));
                  try {
                    File? file = await createCameraImage();
                    debugPrint("🟣 [showSingleImageSheet] Camera file created: ${file?.path}");
                    if (!completer.isCompleted) {
                      completer.complete(file);
                      debugPrint("🟣 [showSingleImageSheet] Completer completed with camera file");
                    }
                  } catch (e) {
                    debugPrint('🔴 [showSingleImageSheet] Error in camera access: $e');
                    if (!completer.isCompleted) {
                      completer.complete(null);
                      debugPrint("🟣 [showSingleImageSheet] Completer completed with null due to error");
                    }
                  }
                },
              ),

              ListTile(
                leading: Icon(Icons.camera_alt, color: AppPalettes.blackColor),
                title: TranslatedText(
                  text: 'Choose from Files',
                  style: AppStyles.bodyMedium,
                ),
                onTap: () async {
                  debugPrint("🟣 [showSingleImageSheet] Files option tapped");
                  optionSelected = true;
                  RouteManager.pop();
                  File? file = await pickSingleFile(isImage: isImage);
                  debugPrint("🟣 [showSingleImageSheet] File picked: ${file?.path}");
                  if (!completer.isCompleted) {
                    completer.complete(file);
                    debugPrint("🟣 [showSingleImageSheet] Completer completed with file");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ).then((value) {
      debugPrint("🟣 [showSingleImageSheet] Bottom sheet dismissed with value: ${value?.path}, optionSelected: $optionSelected");
      // Only complete with null if user dismissed without selecting an option
      // If optionSelected is true, the completer will be completed from the onTap handler
      if (!optionSelected && !completer.isCompleted) {
        completer.complete(null);
        debugPrint("🟣 [showSingleImageSheet] Completer completed with null (dismissed without selection)");
      } else if (value != null && !completer.isCompleted) {
        completer.complete(value);
        debugPrint("🟣 [showSingleImageSheet] Completer completed with value from then");
      } else {
        debugPrint("🟣 [showSingleImageSheet] Not completing completer from then() - option was selected, will complete from onTap");
      }
    });
    
    return completer.future;
  }
}
