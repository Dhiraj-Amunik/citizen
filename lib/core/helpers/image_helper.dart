import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';

// For picking multiple images with size validation
Future pickMultipleImages() async {
  List<File> selectedImages = [];
  final ImagePicker imagePicker = ImagePicker();

  try {
    final List<XFile>? pickedFiles = await imagePicker.pickMultiImage(
      limit: 5, // Maximum number of images
      imageQuality: 20, // Reduce quality to save space
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      const maxSizeInBytes = 1.8 * 1024 * 1024; // 2MB limit

      for (XFile pickedFile in pickedFiles) {
        final fileSize = await pickedFile.length();

        if (fileSize > maxSizeInBytes) {
          CommonSnackbar(
            text: "Image ${pickedFile.name} exceeds 2MB limit. Skipping.",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          continue; // Skip this file but continue with others
        }

        selectedImages.add(File(pickedFile.path));
      }

      return selectedImages;
    }
  } catch (e) {
    log("Error picking multiple images: $e");
    CommonSnackbar(
      text: "Error selecting images",
    ).showAnimatedDialog(type: QuickAlertType.error);
  }

  return []; // Return empty list if no images selected
}

Future pickFiles() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Allow multiple file selection
      type: FileType.custom, // Custom file types
      compressionQuality: 20,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      const maxSizeInBytes = 1.8 * 1024 * 1024;
      List<File> selectedFiles = [];

      for (PlatformFile platformFile in result.files) {
        if (platformFile.size > maxSizeInBytes) {
          CommonSnackbar(
            text: "File ${platformFile.name} exceeds 2MB limit. Skipping.",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          continue;
        }

        if (platformFile.path != null) {
          selectedFiles.add(File(platformFile.path!));
        }
      }

      return selectedFiles;
    }
  } catch (e) {
    log("Error picking files: $e");
    CommonSnackbar(
      text: "Error selecting files",
    ).showAnimatedDialog(type: QuickAlertType.error);
  }

  return []; // Return empty list if no files selected
}

// For picking single image from gallery
Future<File?> pickGalleryImage() async {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  try {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    if (await checkImageSize(pickedFile) == true) {
      selectedImage = File(pickedFile!.path);
      return selectedImage;
    }
  } catch (e) {
    log("Error picking gallery image: $e");
    CommonSnackbar(
      text: "Error selecting image",
    ).showAnimatedDialog(type: QuickAlertType.error);
  }

  return null;
}

// For capturing image from camera
Future<dynamic> createCameraImage() async {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  try {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 20, // Added compression for camera too
    );

    if (await checkImageSize(pickedFile) == true) {
      selectedImage = File(pickedFile!.path);
      return selectedImage;
    }
  } catch (e) {
    log("Error capturing camera image: $e");
    CommonSnackbar(
      text: "Error capturing image",
    ).showAnimatedDialog(type: QuickAlertType.error);
  }

  return null;
}

Future<dynamic> createImage() async {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  try {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 20, // Added compression for camera too
    );

    if (await checkImageSize(pickedFile) == true) {
      selectedImage = File(pickedFile!.path);
      return [selectedImage];
    }
  } catch (e) {
    log("Error capturing camera image: $e");
    CommonSnackbar(
      text: "Error capturing image",
    ).showAnimatedDialog(type: QuickAlertType.error);
  }

  return null;
}

Future<File?> pickSingleFile({bool isImage = false}) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      compressionQuality: 20,
      allowedExtensions: isImage
          ? ['jpg', 'jpeg', 'png']
          : ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    const maxSizeInBytes = 1.8 * 1024 * 1024; // 2MB limit

    if (result != null && result.files.isNotEmpty) {
      PlatformFile platformFile = result.files.first;

      if (platformFile.size > maxSizeInBytes) {
        CommonSnackbar(
          text:
              "File ${platformFile.name} exceeds 2MB limit. Please choose a smaller file.",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return null;
      }

      if (platformFile.path != null) {
        return File(platformFile.path!);
      }
    }
  } catch (e) {
    log("Error picking file: $e");
    CommonSnackbar(
      text: "Error selecting file",
    ).showAnimatedDialog(type: QuickAlertType.error);
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
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      if (!await dir.exists()) dir = await getExternalStorageDirectory();
    }
  } catch (err) {
    print("Cannot get download folder path $err");
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
    print("Cannot get download folder path $err");
  }
  return dir?.path;
}

Future<bool> checkImageSize(XFile? image) async {
  if (image != null) {
    const maxSizeInBytes = 2 * 1024 * 1024; // 2MB
    final fileSize = await image.length();

    if (fileSize > maxSizeInBytes) {
      CommonSnackbar(
        text: "Image too large. Maximum allowed: 2MB",
      ).showAnimatedDialog(type: QuickAlertType.warning);
    } else {
      return true;
    }
  }
  return false;
}
