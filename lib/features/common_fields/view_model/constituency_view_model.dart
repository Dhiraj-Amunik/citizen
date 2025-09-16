import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/common_fields/model/request_pincode_model.dart';
import 'package:inldsevak/features/common_fields/services/constituencies_repository.dart';
import 'package:inldsevak/features/complaints/model/response/constituency_model.dart'
    as constituency;
// import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';

class ConstituencyViewModel extends BaseViewModel {
  List<constituency.Data> constituencyLists = [];

  // Future<void> getConstituencies() async {
  //   try {
  //     final response = await ComplaintsRepository().getConstituencies(token);
  //     if (response.data?.responseCode == 200) {
  //       final data = response.data?.data;
  //       if (data?.isEmpty == true) {
  //         CommonSnackbar(text: "No constituencies found").showToast();
  //       } else {
  //         constituencyLists = List<constituency.Data>.from(data as List);
  //         notifyListeners();
  //       }
  //     }
  //   } catch (err, stackTrace) {
  //     debugPrint("Error: $err");
  //     debugPrint("Stack Trace: $stackTrace");
  //   }
  // }

  Future<void> getConstituenciesWithPincode({String? pincode}) async {
    try {
      final model = RequestPincodeModel(pincode: pincode);
      final response = await ConstituenciesRepository()
          .getPincodeConstituencies(token: token, model: model);
      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(text: "No constituencies found").showToast();
        } else {
          constituencyLists = List<constituency.Data>.from(data as List);
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }
}
