import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:quickalert/models/quickalert_type.dart';

mixin HandleMultipleFilesSheet {
  // Camera lock to prevent double-tap crashes on low-RAM devices
  // Using static to work with StatelessWidget (@immutable)
  static bool _isCameraOpening = false;

  Widget selectMultipleFiles({required Function(Future<dynamic>) onTap, BuildContext? context}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.camera),
          title: TranslatedText(text: 'Take a Picture'),
          onTap: () {
            // 🔥 SAFE: Close bottom sheet first, then wait for next frame
            if (context != null) {
              Navigator.pop(context);
              // Wait for bottom sheet to fully dispose before opening camera
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openCameraSafely(onTap);
              });
            } else {
              _openCameraSafely(onTap);
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: TranslatedText(text: 'Choose from Gallery'),
          onTap: () async {
            if (context != null) {
              Navigator.pop(context);
            }
            try {
              final files = await pickMultipleImages();
              onTap(Future.value(files));
            } catch (err) {
              debugPrint("Error picking images: $err");
              CommonSnackbar(
                text: "Failed to select images. Please try again.",
              ).showAnimatedDialog(type: QuickAlertType.error);
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.file_open),
          title: TranslatedText(text: 'Choose from Files'),
          onTap: () async {
            if (context != null) {
              Navigator.pop(context);
            }
            try {
              final files = await pickFiles();
              onTap(Future.value(files));
            } catch (err) {
              debugPrint("Error picking files: $err");
              CommonSnackbar(
                text: "Failed to select files. Please try again.",
              ).showAnimatedDialog(type: QuickAlertType.error);
            }
          },
        ),
      ],
    );
  }

  /// 🔥 SAFE CAMERA OPEN - Prevents crashes on low-RAM devices
  /// Uses lock to prevent double-tap, waits for bottom sheet disposal
  Future<void> _openCameraSafely(Function(Future<dynamic>) onTap) async {
    // Prevent double-tap camera launch (causes crash on low-RAM devices)
    if (_isCameraOpening) return;
    _isCameraOpening = true;

    try {
      // Extra delay for low-RAM devices to ensure widget tree is stable
      await Future.delayed(const Duration(milliseconds: 400));

      // Process image capture with additional error handling
      final files = await createImage();
      
      // Additional delay after image capture to let system stabilize (critical for older devices)
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (files.isNotEmpty) {
        // Validate files before passing to onTap
        final validFiles = <File>[];
        for (final file in files) {
          try {
            // Check if file exists and is valid
            if (await file.exists()) {
              final fileSize = await file.length();
              // Only add if file size is reasonable (max 5MB)
              if (fileSize > 0 && fileSize < 5 * 1024 * 1024) {
                validFiles.add(file);
              } else {
                debugPrint("File size invalid: $fileSize bytes");
              }
            }
          } catch (e) {
            debugPrint("Error validating file: $e");
            // Continue with other files even if one fails
          }
        }
        
        if (validFiles.isNotEmpty) {
          // Use microtask to ensure UI is ready before processing
          await Future.microtask(() {
            onTap(Future.value(validFiles));
          });
        } else {
          CommonSnackbar(
            text: "Image file is invalid. Please try again.",
          ).showAnimatedDialog(type: QuickAlertType.error);
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error capturing image: $err");
      debugPrint("Stack trace: $stackTrace");
      CommonSnackbar(
        text: "Failed to capture image. Please try again.",
      ).showAnimatedDialog(type: QuickAlertType.error);
    } finally {
      // Additional delay before releasing lock to prevent rapid re-triggers
      await Future.delayed(const Duration(milliseconds: 200));
      _isCameraOpening = false;
    }
  }
}
