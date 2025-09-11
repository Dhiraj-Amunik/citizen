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

  Future<void> getMLALists() async {
    showCustomDialogTransperent(isShowing: true);
    try {
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
}
