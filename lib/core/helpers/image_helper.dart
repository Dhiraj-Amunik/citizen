import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';

/// 🔥 BASIC IMAGE HELPER (SAFE FOR OLD DEVICES)
/// Lowest memory usage, no byte-buffer loading, strict camera limits
class BasicImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// ===============================
  /// 📷 CAMERA IMAGE (MOST SAFE)
  /// ===============================
  static Future<File?> pickFromCamera() async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        // 🔥 STRICT LIMITS — DO NOT CHANGE
        imageQuality: 35,
        maxWidth: 640,
        maxHeight: 640,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (xFile == null) return null;

      // Direct file usage (NO readAsBytes)
      final File file = File(xFile.path);

      if (!await file.exists()) return null;

      // Optional size check (safe)
      final int size = await file.length();
      if (size > 2 * 1024 * 1024) {
        return null;
      }

      return file;
    } catch (e) {
      log('Camera image error: $e');
      return null;
    }
  }

  /// ===============================
  /// 🖼 GALLERY IMAGE (SINGLE)
  /// ===============================
  static Future<File?> pickFromGallery() async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (xFile == null) return null;

      final File file = File(xFile.path);
      if (!await file.exists()) return null;

      return file;
    } catch (e) {
      log('Gallery image error: $e');
      return null;
    }
  }

  /// ===============================
  /// 🖼 GALLERY MULTI (MAX 3)
  /// ===============================
  static Future<List<File>> pickMultipleFromGallery() async {
    final List<File> images = [];

    try {
      final List<XFile>? files = await _picker.pickMultiImage(
        imageQuality: 40,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (files == null || files.isEmpty) return images;

      for (final xFile in files.take(3)) {
        final file = File(xFile.path);
        if (await file.exists()) {
          images.add(file);
        }
      }
    } catch (e) {
      log('Multi image error: $e');
    }

    return images;
  }

  /// ===============================
  /// 📁 TEMP DIRECTORY (OPTIONAL)
  /// ===============================
  static Future<String> tempPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }
}

// ===============================
// 🔄 COMPATIBILITY WRAPPERS
// ===============================
// These maintain backward compatibility with existing code

/// Compatibility wrapper for pickGalleryImage()
Future<File?> pickGalleryImage() async {
  return await BasicImageHelper.pickFromGallery();
}

/// Compatibility wrapper for createCameraImage()
Future<File?> createCameraImage() async {
  return await BasicImageHelper.pickFromCamera();
}

/// Compatibility wrapper for pickMultipleImages()
Future<List<File>> pickMultipleImages() async {
  return await BasicImageHelper.pickMultipleFromGallery();
}

/// Compatibility wrapper for createImage()
Future<List<File>> createImage() async {
  final file = await BasicImageHelper.pickFromCamera();
  if (file == null) return [];
  return [file];
}

/// File picker for documents (kept for compatibility)
Future<List<File>> pickFiles() async {
  try {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.isEmpty) return [];

    const maxSizeInBytes = 1.8 * 1024 * 1024;
    final List<File> selectedFiles = [];

    for (final PlatformFile pf in result.files) {
      if (pf.size > maxSizeInBytes) {
        CommonSnackbar(
          text: 'File ${pf.name} exceeds 2MB limit. Skipping.',
        ).showAnimatedDialog(type: QuickAlertType.warning);
        continue;
      }
      if (pf.path != null) selectedFiles.add(File(pf.path!));
    }

    return selectedFiles;
  } catch (e) {
    log('Error picking files: $e');
    CommonSnackbar(text: 'Error selecting files').showAnimatedDialog(type: QuickAlertType.error);
    return [];
  }
}

/// Single file picker (kept for compatibility)
Future<File?> pickSingleFile({bool isImage = false}) async {
  try {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: isImage 
          ? ['jpg', 'jpeg', 'png'] 
          : ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.isEmpty) return null;

    final PlatformFile pf = result.files.first;
    const maxSizeInBytes = 1.8 * 1024 * 1024;
    if (pf.size > maxSizeInBytes) {
      CommonSnackbar(
        text: 'File ${pf.name} exceeds 2MB limit. Please choose a smaller file.',
      ).showAnimatedDialog(type: QuickAlertType.warning);
      return null;
    }

    if (pf.path != null) return File(pf.path!);
  } catch (e) {
    log('Error picking file: $e');
    CommonSnackbar(text: 'Error selecting file').showAnimatedDialog(type: QuickAlertType.error);
  }
  return null;
}

/// Get file path (kept for compatibility)
Future<String?> getFilePath() async {
  try {
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } else {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir.path;
      final extDir = await getExternalStorageDirectory();
      return extDir?.path;
    }
  } catch (err) {
    log('Cannot get download folder path: $err');
    return null;
  }
}

/// Get temp path (kept for compatibility)
Future<String?> getTempPath() async {
  try {
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } else {
      final dir = await getTemporaryDirectory();
      return dir.path;
    }
  } catch (err) {
    log('Cannot get temp folder path: $err');
    return null;
  }
}
