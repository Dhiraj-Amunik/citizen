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

class RequestAppointmentViewModel extends BaseViewModel
    with CupertinoDialogMixin, TransparentCircular {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  final mlaController = SingleSelectController<mla.Data>(null);
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final dateController = TextEditingController();
  final timeSlotController = SingleSelectController<String>(null);
  final purposeOfAppointmentController = SingleSelectController<String>(null);
  final descriptionController = TextEditingController();
  String? companyDateFormat;
  File? image;
  List<mla.Data> mlaLists = [];
  List<String> timeSlotLists = ["12:00", "02:00", "03:00"];
  List<String> purposeLists = ["Testing"];

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
    getMLALists();
    return super.onInit();
  }

  Future<void> getMLALists() async {
    try {
      showCustomDialogTransperent(isShowing: true);
      final response = await AppointmentsRepository().getMLAsData(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(
            text: "No MLA's Found !",
          ).showAnimatedDialog(type: QuickAlertType.info);
        } else {
          mlaLists.addAll(List.from(data as List));
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      showCustomDialogTransperent(isShowing: false);
    }
  }

  Future<void> requestNewAppointments() async {
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
        timeSlot: timeSlotController.value ?? "",
        purpose: purposeOfAppointmentController.value ?? "",
        reason: descriptionController.text,
        documents: [],
        mlaId: mlaController.value!.sId!,
        priority: Priority.high,
      );

      final response = await AppointmentsRepository().newAppointment(
        token,
        model: data,
      );

      if (response.data?.responseCode == 200) {
        await CommonSnackbar(
          text: "Appointment has been scheduled successfully.",
        ).showAnimatedDialog(type: QuickAlertType.success);
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
}
