import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/services/notify_repository.dart';
import 'package:quickalert/quickalert.dart';

class CreateNotifyRepresentativeViewModel extends BaseViewModel
    with UploadFilesMixin {
  final _repository = NotifyRepository();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final eventTypeController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final eventTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final streetController = TextEditingController();
  final pincodeController = TextEditingController();

  final mlaController = SingleSelectController<MlaFilter>(null);
  final districtController = TextEditingController();
  final mandalController = TextEditingController();
  final villageController = TextEditingController();

  String? companyDateFormat;
  LocationCoordinates? locationCoordinates;
  NotifyFiltersData? filtersData;

  List<File> multipleFiles = [];

  @override
  Future<void> onInit() {
    getNotifyFilters();
    return super.onInit();
  }

  Future<void> getNotifyFilters() async {
    try {
      final response = await _repository.getNotifyFilters(token: token);
      if (response.data?.responseCode == 200) {
        filtersData = response.data?.data;
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error fetching filters: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> addFiles(Future<dynamic> future) async {
    RouteManager.pop();
    try {
      final data = await future;
      if (data != null) {
        List<File> tempFiles = [...multipleFiles];
        tempFiles.addAll(data);
        if (tempFiles.length >= 6) {
          return CommonSnackbar(
            text: "Max 5 Files are accepted",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
          multipleFiles.addAll(await future);
          notifyListeners();
        }
      }
    } catch (err) {
      debugPrint("-------->$err");
    }
  }

  void removeImage(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  Future<void> requestNotify({required Function onCompleted}) async {
    try {
      // Validate all form fields including dropdown
      if (!formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      
      // Additional check for MLA dropdown as backup (since dropdown validation might need explicit check)
      if (mlaController.value == null) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        CommonSnackbar(text: 'Please select MLA').showToast();
        notifyListeners();
        return;
      }
      
      autoValidateMode = AutovalidateMode.disabled;
      isLoading = true;

      final data = RequestNotifytModel(
        title: eventTypeController.text.trim(),
        location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
        eventDate: companyDateFormat ?? "",
        eventTime: eventTimeController.text.trim(),
        description: descriptionController.text.trim(),
        documents: multipleFiles.isEmpty
            ? []
            : await uploadMultipleImage(multipleFiles),
        mlaId: mlaController.value?.sId,
        locationCoordinates: locationCoordinates,
        district: districtController.text.trim(),
        mandal: mandalController.text.trim(),
        village: villageController.text.trim(),
        street: streetController.text.trim(),
        pincode: pincodeController.text.trim(),
      );

      final response = await _repository.createNotify(
        token: token,
        model: data,
      );

      if (response.data?.responseCode == 200) {
        onCompleted();
        await CommonSnackbar(
          text: "Notify has been requested sucessfully",
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

  clear() {
    eventTypeController.clear();
    locationController.clear();
    companyDateFormat = "";
    dateController.clear();
    eventTimeController.clear();
    descriptionController.clear();
    streetController.clear();
    pincodeController.clear();
    mlaController.value = null;
    districtController.clear();
    mandalController.clear();
    villageController.clear();
    locationCoordinates = null;
    multipleFiles..clear();
  }
}
