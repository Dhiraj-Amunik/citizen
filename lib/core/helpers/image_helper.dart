import 'dart:io';
import 'package:image_picker/image_picker.dart';

pickMultipleImagePath() async {
  List<File> selectedImages = [];
  final ImagePicker imagePicker = ImagePicker();
  final List<XFile>? pickedFiles = await imagePicker.pickMultiImage();
  if (pickedFiles != null && pickedFiles.isNotEmpty) {
    selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    return selectedImages;
  }
  throw "Unable to process Images";
}

pickGalleryImage() async {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();
  final XFile? pickedFile = await imagePicker.pickImage(
    source: ImageSource.gallery,
  );

  if (pickedFile != null) {
    selectedImage = File(pickedFile.path);
    return selectedImage;
  } else {
    return null;
  }
}

createCameraImage() async {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();
  final XFile? pickedFile = await imagePicker.pickImage(
    source: ImageSource.camera,
  );

  if (pickedFile != null) {
    selectedImage = File(pickedFile.path);
    return selectedImage;
  } else {
    return null;
  }
}
