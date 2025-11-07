import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/common_fields/model/request_parliment_id_model.dart';
import 'package:inldsevak/features/common_fields/model/request_pincode_model.dart';
import 'package:inldsevak/features/common_fields/services/constituencies_repository.dart';

import 'package:quickalert/models/quickalert_type.dart';

class ConstituencyViewModel extends BaseViewModel {
  List<Constituency?> assemblyConstituencyLists = [];
  List<Constituency?> parliamentaryConstituencyLists = [];

  Future<String?> getParliamentaryConstituencies({
    required String pincode,
    required SingleSelectController<Constituency?> parlimentController,
  }) async {
    try {
      if (pincode.length != 6) {
        CommonSnackbar(
          text: "Please enter a valid Pincode !",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return null;
      }
      final intCode = int.tryParse(pincode);
      final model = RequestPincodeModel(pincode: intCode);
      final response = await ConstituenciesRepository()
          .getParliamentaryConstituencies(token: token, model: model);
      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          await CommonSnackbar(
            text: "No Constituencies Found !",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
          parlimentController.clear();
          parliamentaryConstituencyLists = List<Constituency>.from(
            data as List,
          );
          if (parliamentaryConstituencyLists.isNotEmpty) {
            parlimentController.value = parliamentaryConstituencyLists.first;
          }
          notifyListeners();
          return response.data?.district;
        }
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "No Constituencies Found !",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      await CommonSnackbar(
        text: "Something went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return null;
  }

  Future<void> getAssemblyConstituencies({
    required String? id,
    String? oldToken,
  }) async {
    try {
      assemblyConstituencyLists.clear();
      final model = RequestParlimentIdModel(id: id);
      final response = await ConstituenciesRepository()
          .getAssemblyConstituencies(token: oldToken ?? token, model: model);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          await CommonSnackbar(
            text: "No Constituencies Found !",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
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
