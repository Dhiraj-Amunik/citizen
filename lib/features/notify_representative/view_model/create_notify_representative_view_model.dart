import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
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

  String? companyDateFormat;

  List<File> multipleFiles = [];

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
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;

      final data = RequestNotifytModel(
        title: eventTypeController.text,
        location: locationController.text,
        eventDate: companyDateFormat ?? "",
        eventTime: eventTimeController.text,
        description: descriptionController.text,
        documents: multipleFiles.isEmpty
            ? []
            : await uploadMultipleImage(multipleFiles),
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
    multipleFiles..clear();
  }
}
