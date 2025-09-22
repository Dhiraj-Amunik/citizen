import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart'; // Add this import
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:quickalert/models/quickalert_type.dart';

// For picking multiple images with size validation
pickMultipleImages() async {
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

        log("===================>${fileSize.toInt().toString()}");
        log("===================>$maxSizeInBytes");

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

// For picking single image from gallery
pickGalleryImage() async {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  try {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      const maxSizeInBytes = 2 * 1024 * 1024; // 2MB
      final fileSize = await pickedFile.length();

      if (fileSize > maxSizeInBytes) {
        CommonSnackbar(
          text: "Image too large. Maximum allowed: 2MB",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return null;
      }

      selectedImage = File(pickedFile.path);
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
createCameraImage() async {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  try {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Added compression for camera too
    );

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
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

// NEW: For picking files (documents, PDFs, etc.)
// pickFiles() async {
//   try {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true, // Allow multiple file selection
//       type: FileType.custom, // Custom file types
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
//     );

//     if (result != null && result.files.isNotEmpty) {
//       const maxSizeInBytes = 5 * 1024 * 1024; // 5MB limit for files
//       List<File> selectedFiles = [];
      
//       for (PlatformFile platformFile in result.files) {
//         if (platformFile.size > maxSizeInBytes) {
//           CommonSnackbar(
//             text: "File ${platformFile.name} exceeds 5MB limit. Skipping.",
//           ).showAnimatedDialog(type: QuickAlertType.warning);
//           continue;
//         }
        
//         if (platformFile.path != null) {
//           selectedFiles.add(File(platformFile.path!));
//         }
//       }
      
//       return selectedFiles;
//     }
//   } catch (e) {
//     log("Error picking files: $e");
//     CommonSnackbar(
//       text: "Error selecting files",
//     ).showAnimatedDialog(type: QuickAlertType.error);
//   }
  
//   return []; // Return empty list if no files selected
// }