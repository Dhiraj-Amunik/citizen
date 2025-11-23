import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';

// Helper to pick multiple images with size validation
Future<List<File>> pickMultipleImages() async {
  final List<File> selectedImages = [];
  final ImagePicker imagePicker = ImagePicker();

  try {
    final List<XFile>? pickedFiles = await imagePicker.pickMultiImage(
      limit: 5,
      imageQuality: 20,
    );

    if (pickedFiles == null || pickedFiles.isEmpty) return [];

    const maxSizeInBytes = 1.8 * 1024 * 1024; // ~1.8MB

    for (final XFile xf in pickedFiles) {
      try {
        final int size = await xf.length();
        if (size > maxSizeInBytes) {
          final name = _safeBasename(xf.path);
          CommonSnackbar(
            text: "Image $name exceeds 2MB limit. Skipping.",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          continue;
        }

        final File? file = await _ensureFileFromXFile(xf);
        if (file != null) selectedImages.add(file);
      } catch (e) {
        log('Error handling picked file: $e');
      }
    }
  } catch (e) {
    log('Error picking multiple images: $e');
    CommonSnackbar(text: 'Error selecting images').showAnimatedDialog(type: QuickAlertType.error);
  }

  return selectedImages;
}

Future<List<File>> pickFiles() async {
  try {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      compressionQuality: 20,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.isEmpty) return [];

    const maxSizeInBytes = 1.8 * 1024 * 1024;
    final List<File> selectedFiles = [];

    for (final PlatformFile pf in result.files) {
      if (pf.size > maxSizeInBytes) {
        CommonSnackbar(text: 'File ${pf.name} exceeds 2MB limit. Skipping.').showAnimatedDialog(type: QuickAlertType.warning);
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

Future<File?> pickGalleryImage() async {
  final ImagePicker imagePicker = ImagePicker();
  try {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (pickedFile == null) return null;

    if (await checkImageSize(pickedFile) != true) return null;

    // Try a few times to ensure file is available (some devices delay writing)
    const int attempts = 3;
    for (int i = 0; i < attempts; i++) {
      final File? file = await _ensureFileFromXFile(pickedFile);
      if (file != null) return file;
      await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
    }
    // Final attempt failed
    CommonSnackbar(text: 'Temporary issue reading image. Please try again.').showAnimatedDialog(type: QuickAlertType.error);
    return null;
  } catch (e, st) {
    log('Error picking gallery image: $e');
    log('$st');
    if (e.toString().toLowerCase().contains('cancel')) return null;
    CommonSnackbar(text: 'Error selecting image').showAnimatedDialog(type: QuickAlertType.error);
    return null;
  }
}

Future<File?> createCameraImage() async {
  return _pickSingleImage(
    ImageSource.camera,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 60,
  );
}

Future<List<File>> createImage() async {
  final f = await createCameraImage();
  if (f == null) return [];
  return [f];
}

Future<File?> _pickSingleImage(
  ImageSource source, {
  int maxWidth = 1280,
  int maxHeight = 1280,
  int imageQuality = 75,
}) async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
    );

    if (pickedFile == null) return null;

    // Small delay to let OS finish writing file on some devices
    await Future.delayed(const Duration(milliseconds: 200));

    if (await checkImageSize(pickedFile) != true) return null;

    // Try to obtain a usable File object with retries
    const int attempts = 3;
    for (int i = 0; i < attempts; i++) {
      final File? file = await _ensureFileFromXFile(pickedFile);
      if (file != null) return file;
      await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
    }

    CommonSnackbar(text: 'Temporary issue reading image. Please try again.').showAnimatedDialog(type: QuickAlertType.error);
    return null;
  } catch (e, st) {
    log('Error capturing image: $e');
    log('$st');
    String errorMessage = 'Error capturing image';
    if (e.toString().toLowerCase().contains('permission')) {
      errorMessage = 'Camera permission denied. Please enable it in settings.';
    } else if (e.toString().toLowerCase().contains('not available')) {
      errorMessage = 'Camera is not available on this device.';
    } else if (e.toString().toLowerCase().contains('cancel')) {
      return null;
    }
    CommonSnackbar(text: errorMessage).showAnimatedDialog(type: QuickAlertType.error);
    return null;
  }
}

// Ensure we have a regular File object to work with. Handles content:// URIs by
// reading bytes from the XFile and writing to a temp file.
Future<File?> _ensureFileFromXFile(XFile pickedFile) async {
  try {
    final String path = pickedFile.path;
    final File possibleFile = File(path);

    // If file exists on filesystem, prefer it
    final bool possibleExists = await possibleFile.exists();
    log('ensureFileFromXFile: path=$path exists=$possibleExists');
    if (possibleExists) {
      // Verify readability and non-empty
      try {
        final int len = await possibleFile.length();
        log('possibleFile length=$len');
        if (len > 0) return possibleFile;
      } catch (e) {
        log('Error reading possibleFile: $e');
        // Fall through to create temp copy
      }
    }

    // Otherwise, write bytes to a temp file (covers content:// URIs)
    final tempDir = await getTemporaryDirectory();
    final baseName = _safeBasename(pickedFile.path);
    final targetFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_$baseName');

    // Attempt writing using a streaming approach to avoid large memory spikes
    // and reduce chance of OOM. Retry on transient failures.
    int writeAttempts = 0;
    const int maxWriteAttempts = 3;
    while (writeAttempts < maxWriteAttempts) {
      try {
        log('Attempt ${writeAttempts + 1} to stream-write to $targetFile');
        final IOSink sink = targetFile.openWrite();
        await for (final chunk in pickedFile.openRead()) {
          sink.add(chunk);
        }
        await sink.flush();
        await sink.close();

        if (await targetFile.exists()) {
          final int len = await targetFile.length();
          log('Wrote targetFile length=$len');
          if (len > 0) return targetFile;
        }
      } catch (e) {
        log('Stream write failed (attempt ${writeAttempts + 1}): $e');
        // Fallback to readAsBytes for this attempt
        try {
          final Uint8List bytes = await pickedFile.readAsBytes();
          await targetFile.writeAsBytes(bytes);
          if (await targetFile.exists() && await targetFile.length() > 0) return targetFile;
        } catch (e2) {
          log('Fallback writeAsBytes failed: $e2');
        }
      }

      writeAttempts++;
      // small backoff
      await Future.delayed(Duration(milliseconds: 200 * writeAttempts));
    }

    return null;
  } catch (e) {
    log('Error ensuring file from XFile: $e');
    return null;
  }
}

Future<File?> pickSingleFile({bool isImage = false}) async {
  try {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      compressionQuality: 20,
      allowedExtensions: isImage ? ['jpg', 'jpeg', 'png'] : ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.isEmpty) return null;

    final PlatformFile pf = result.files.first;
    const maxSizeInBytes = 1.8 * 1024 * 1024;
    if (pf.size > maxSizeInBytes) {
      CommonSnackbar(text: 'File ${pf.name} exceeds 2MB limit. Please choose a smaller file.').showAnimatedDialog(type: QuickAlertType.warning);
      return null;
    }

    if (pf.path != null) return File(pf.path!);
  } catch (e) {
    log('Error picking file: $e');
    CommonSnackbar(text: 'Error selecting file').showAnimatedDialog(type: QuickAlertType.error);
  }
  return null;
}

Future<String?> getFilePath() async {
  Directory? dir;
  try {
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) dir = await getExternalStorageDirectory();
    }
  } catch (err) {
    log('Cannot get download folder path: $err');
  }
  return dir?.path;
}

Future<String?> getTempPath() async {
  Directory? dir;
  try {
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getTemporaryDirectory();
    }
  } catch (err) {
    log('Cannot get temp folder path: $err');
  }
  return dir?.path;
}

Future<bool> checkImageSize(XFile? image) async {
  if (image == null) return false;
  const maxSizeInBytes = 2 * 1024 * 1024; // 2MB
  try {
    final fileSize = await image.length();
    if (fileSize > maxSizeInBytes) {
      CommonSnackbar(text: 'Image too large. Maximum allowed: 2MB').showAnimatedDialog(type: QuickAlertType.warning);
      return false;
    }
    return true;
  } catch (e) {
    log('Error checking image size: $e');
    return false;
  }
}

String _safeBasename(String? pathStr) {
  try {
    if (pathStr == null || pathStr.isEmpty) return 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    if (pathStr.startsWith('content://')) return 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final name = p.basename(pathStr);
    return name.isNotEmpty ? name : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  } catch (_) {
    return 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

}