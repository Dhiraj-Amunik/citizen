import 'package:flutter/material.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart'
    as mla;
import 'package:inldsevak/features/quick_access/appointments/services/appointments_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';

class MlaViewModel extends BaseViewModel with TransparentCircular {
  @override
  Future<void> onInit() {
    getMLALists();
    return super.onInit();
  }

  List<mla.Data> mlaLists = [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;

  Future<void> getMLALists() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    showCustomDialogTransperent(isShowing: true);
    try {
      final response = await AppointmentsRepository().getMLAsData(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data ?? <mla.Data>[];
        mlaLists
          ..clear()
          ..addAll(List<mla.Data>.from(data));
        if (mlaLists.isEmpty) {
          errorMessage = "No MLA's Found !";
          CommonSnackbar(
            text: errorMessage,
          ).showAnimatedDialog(type: QuickAlertType.info);
        }
      } else {
        errorMessage = response.data?.message ?? "Unable to fetch MLA list";
        CommonSnackbar(text: errorMessage).showToast();
      }
    } catch (err, stackTrace) {
      errorMessage = "Something went wrong, please try again.";
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      CommonSnackbar(text: errorMessage).showToast();
    } finally {
      showCustomDialogTransperent(isShowing: false);
      isLoading = false;
      hasLoaded = true;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await getMLALists();
  }
}
