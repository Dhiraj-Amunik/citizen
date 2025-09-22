import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart'
    as mla;
import 'package:inldsevak/features/quick_access/appointments/model/request_appointment_model.dart';
import 'package:inldsevak/features/quick_access/appointments/services/appointments_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as profile;

class RequestAppointmentViewModel extends BaseViewModel
    with CupertinoDialogMixin, TransparentCircular {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final dateController = TextEditingController();
  final mlaController = SingleSelectController<mla.Data?>(null);
  // final timeSlotController = SingleSelectController<String>(null);
  final purposeOfAppointmentController = TextEditingController();
  final bookForController = SingleSelectController<BookFor?>(null);
  final descriptionController = TextEditingController();
  String? companyDateFormat;
  File? image;
  List<String> timeSlotLists = ["12:00", "01:00", "02:00", "03:00"];
  List<BookFor> bookForList = [
    BookFor(key: 'self', value: 'My Self'),
    BookFor(key: 'others', value: 'Others'),
  ];

  Future<void> selectImage() async {
    customRightCupertinoDialog(
      content: "Choose Image",
      rightButton: "Sure",
      onTap: () async {
        try {
          image = await pickGalleryImage();
          notifyListeners();
        } catch (err, stackTrace) {
          debugPrint("Error: $err");
          debugPrint("Stack Trace: $stackTrace");
        }
        RouteManager.pop();
      },
    );
  }

  void removeImage() {
    image = null;
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
        // timeSlot: timeSlotController.value ?? "",
        purpose: purposeOfAppointmentController.text,
        reason: descriptionController.text,
        documents: [],
        mlaId: mlaController.value!.sId!,
        priority: Priority.high,
        bookFor: bookForController.value?.key,
        memberShipID: "ABCDEF",
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
          text: response.error?.message ?? "Some thing went wrong",
        ).showAnimatedDialog(type: QuickAlertType.error);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  autoFillData(profile.Data? profile) {
    nameController.text = profile?.name ?? "";
    phoneNumberController.text = profile?.phone ?? "";
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
    companyDateFormat = null;
    // timeSlotController.clear();
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
    // timeSlotController.dispose();
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
