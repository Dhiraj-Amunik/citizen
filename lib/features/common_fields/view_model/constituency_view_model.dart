import 'package:flutter/material.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/common_fields/model/request_parliment_id_model.dart';
import 'package:inldsevak/features/common_fields/model/request_pincode_model.dart';
import 'package:inldsevak/features/common_fields/services/constituencies_repository.dart';

import 'package:quickalert/models/quickalert_type.dart';

class ConstituencyViewModel extends BaseViewModel with TransparentCircular {
  List<Constituency?> assemblyConstituencyLists = [];
  List<Constituency?> parliamentaryConstituencyLists = [];

  Future<void> getParliamentaryConstituencies({required int? pincode}) async {
    try {
      parliamentaryConstituencyLists.clear();
      assemblyConstituencyLists.clear();
      final model = RequestPincodeModel(pincode: pincode);
      final response = await ConstituenciesRepository()
          .getParliamentaryConstituencies(token: token, model: model);
      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          await CommonSnackbar(
            text: "No Constituencies Found !",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
          parliamentaryConstituencyLists = List<Constituency>.from(
            data as List,
          );
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      await CommonSnackbar(
        text: "Something went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> getAssemblyConstituencies({
    required String? id,
    String? oldToken,
  }) async {
    try {
      final model = RequestParlimentIdModel(id: id);
      final response = await ConstituenciesRepository()
          .getAssemblyConstituencies(token: oldToken ?? token, model: model);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(
            text: "No Constituencies Found !",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
          assemblyConstituencyLists.clear();
          assemblyConstituencyLists = List<Constituency>.from(data as List);
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      await CommonSnackbar(
        text: "Something went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }
}
