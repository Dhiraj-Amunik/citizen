import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';
import 'package:inldsevak/features/notify_representative/services/notify_repository.dart';
import 'package:quickalert/quickalert.dart';

class UpdateNotifyRepresentativeViewModel extends BaseViewModel
    with UploadFilesMixin {
  late NotifyRepresentative notify;
  UpdateNotifyRepresentativeViewModel(NotifyRepresentative data) {
    addData(data);
    notify = data;
  }
  final _repository = NotifyRepository();

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
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final eventTypeController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final eventTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final streetController = TextEditingController();
  final pincodeController = TextEditingController();

  final districtController = TextEditingController();
  final mandalController = TextEditingController();
  final villageController = TextEditingController();

  String? companyDateFormat;
  NotifyFiltersData? filtersData;

  List<File> multipleFiles = [];
  final List<String> _existingDocuments = [];
  List<String> get existingDocuments => List.unmodifiable(_existingDocuments);

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

  void removeExistingDocument(int index) {
    if (index < 0 || index >= _existingDocuments.length) return;
    _existingDocuments.removeAt(index);
    notifyListeners();
  }

  Future<void> requestNotify({required Function onCompleted}) async {
    try {
      // Validate all form fields
      if (!formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
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
        documents: [
          ..._existingDocuments,
          if (multipleFiles.isNotEmpty)
            ...await uploadMultipleImage(multipleFiles),
        ],
        id: notify.sId,
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
          text: "Notify has been updated sucessfully",
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

  addData(NotifyRepresentative data) {
    eventTypeController.text = data.title ?? "";
    locationController.text = data.location ?? "";
    companyDateFormat = data.dateAndTime?.toYyyyMmDd();
    dateController.text = data.dateAndTime?.toDdMmYyyy() ?? "";
    eventTimeController.text = data.dateAndTime?.to24HourTime() ?? "";
    descriptionController.text = data.description ?? "";
    streetController.text = data.street ?? "";
    pincodeController.text = data.pincode ?? "";
    districtController.text = data.district ?? "";
    mandalController.text = data.mandal ?? "";
    villageController.text = data.village ?? "";
    _existingDocuments
      ..clear()
      ..addAll(data.documents ?? const []);
  }
}
