import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';

import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart'
    as mla;
import 'package:inldsevak/features/quick_access/appointments/model/request_appointment_model.dart';
import 'package:inldsevak/features/quick_access/appointments/services/appointments_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as profile;

class RequestAppointmentViewModel extends BaseViewModel with UploadFilesMixin {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final dateController = TextEditingController();
  final timeSlotController = TextEditingController();
  final membershipController = TextEditingController();
  final mlaController = SingleSelectController<mla.Data?>(null);
  final purposeOfAppointmentController = TextEditingController();
  final bookForController = SingleSelectController<BookFor?>(null);
  final descriptionController = TextEditingController();
  String? companyDateFormat;
  // File? image;
  List<String> timeSlotLists = ["12:00", "01:00", "02:00", "03:00"];
  List<BookFor> bookForList = [
    BookFor(key: 'self', value: 'My Self'),
    BookFor(key: 'others', value: 'Others'),
  ];

  // Future<void> selectImage() async {
  //   customRightCupertinoDialog(
  //     content: "Choose Image",
  //     rightButton: "Sure",
  //     onTap: () async {
  //       try {
  //         image = await pickGalleryImage();
  //         notifyListeners();
  //       } catch (err, stackTrace) {
  //         debugPrint("Error: $err");
  //         debugPrint("Stack Trace: $stackTrace");
  //       }
  //       RouteManager.pop();
  //     },
  //   );
  // }

  // void removeImage() {
  //   image = null;
  //   notifyListeners();
  // }
  //image
  List<File> multipleFiles = [];
  // Camera lock to prevent double-tap crashes on low-RAM devices
  bool _isCameraOpening = false;

  Widget selectMultipleImages({BuildContext? context}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.camera),
          title: TranslatedText(text: 'Take a Picture'),
          onTap: () {
            // 🔥 SAFE: Close bottom sheet first, then wait for next frame
            final navContext = context ?? RouteManager.navigatorKey.currentState?.context;
            if (navContext != null) {
              Navigator.of(navContext, rootNavigator: true).pop();
              // Wait for bottom sheet to fully dispose before opening camera
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openCameraSafely();
              });
            } else {
              _openCameraSafely();
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: TranslatedText(text: 'Choose from Gallery'),
          onTap: () async {
            final navContext = context ?? RouteManager.navigatorKey.currentState?.context;
            if (navContext != null) {
              Navigator.of(navContext, rootNavigator: true).pop();
            }
            try {
              multipleFiles.addAll(await pickMultipleImages());
              notifyListeners();
            } catch (err) {
              debugPrint("-------->$err");
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.file_open),
          title: TranslatedText(text: 'Choose from Files'),
          onTap: () async {
            final navContext = context ?? RouteManager.navigatorKey.currentState?.context;
            if (navContext != null) {
              Navigator.of(navContext, rootNavigator: true).pop();
            }
            try {
              final files = await pickFiles();
              if (files.isNotEmpty) {
                multipleFiles.addAll(files);
              }
              notifyListeners();
            } catch (err) {
              debugPrint("-------->$err");
            }
          },
        ),
      ],
    );
  }

  /// 🔥 SAFE CAMERA OPEN - Prevents crashes on low-RAM devices
  /// Uses lock to prevent double-tap, waits for bottom sheet disposal
  Future<void> _openCameraSafely() async {
    // Prevent double-tap camera launch (causes crash on low-RAM devices)
    if (_isCameraOpening) return;
    _isCameraOpening = true;

    try {
      // Extra delay for low-RAM devices to ensure widget tree is stable
      await Future.delayed(const Duration(milliseconds: 400));

      final file = await createCameraImage();
      
      // Additional delay after image capture to let system stabilize (critical for older devices)
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (file != null) {
        try {
          // Validate file exists and is valid
          if (await file.exists()) {
            final fileSize = await file.length();
            // Check file size is reasonable (max 5MB) and greater than 0
            if (fileSize > 0 && fileSize < 5 * 1024 * 1024) {
              // Use microtask to ensure UI is ready before processing
              await Future.microtask(() {
                multipleFiles.add(file);
                notifyListeners();
              });
            } else {
              CommonSnackbar(
                text: "Image file is too large or invalid. Please try again.",
              ).showAnimatedDialog(type: QuickAlertType.error);
            }
          } else {
            CommonSnackbar(
              text: "Image file not found. Please try again.",
            ).showAnimatedDialog(type: QuickAlertType.error);
          }
        } catch (fileErr) {
          debugPrint("Error validating file: $fileErr");
          CommonSnackbar(
            text: "Failed to process image. Please try again.",
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

  void removeImage(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  @override
  Future<void> onInit() {
    bookForController.value = bookForList.first;
    return super.onInit();
  }

  Future<void> requestNewAppointments({required Function onCompleted}) async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;

      final data = RequestAppointmentModel(
        name: nameController.text,
        phone: phoneNumberController.text,
        date: companyDateFormat ?? "",
        timeSlot: timeSlotController.text.isEmpty ? "" : timeSlotController.text,
        purpose: purposeOfAppointmentController.text,
        reason: descriptionController.text,
        documents: multipleFiles.isEmpty
            ? []
            : await uploadMultipleImage(multipleFiles),
        mlaId: mlaController.value!.sId!,
        priority: Priority.high,
        bookFor: bookForController.value?.key,
        memberShipID: membershipController.text,
      );

      final response = await AppointmentsRepository().newAppointment(
        token,
        model: data,
      );

      if (response.data?.responseCode == 200) {
        onCompleted();
        await CommonSnackbar(
          text: "Appointment has been requested sucessfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
        RouteManager.pop();
      } else {
        CommonSnackbar(
          text: response.data?.message ?? "Some thing went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      CommonSnackbar(
        text: "Some thing went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  autoFillData(profile.Data? profile) {
    nameController.text = profile?.name ?? "";
    phoneNumberController.text = profile?.phone ?? "";
    membershipController.text = profile?.membershipId ?? "";
  }

  clearAutoFill() {
    nameController.clear();
    phoneNumberController.clear();
  }

  void clear() {
    mlaController.clear();
    bookForController.clear();
    nameController.clear();
    phoneNumberController.clear();
    dateController.clear();
    timeSlotController.clear();
    companyDateFormat = null;
    purposeOfAppointmentController.clear();
    descriptionController.clear();
  }

  @override
  void dispose() {
    mlaController.dispose();
    bookForController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    dateController.dispose();
    timeSlotController.dispose();
    purposeOfAppointmentController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class BookFor {
  final String key;
  final String value;

  const BookFor({required this.key, required this.value});
}
