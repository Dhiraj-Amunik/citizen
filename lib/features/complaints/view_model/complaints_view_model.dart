import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';

class ComplaintsViewModel extends BaseViewModel {
  ComplaintsViewModel() {
    init();
  }

  void init() async {
    await initialize();
    await getComplaints();
  }

  List<Data> complaintsList = [];

  Future<void> getComplaints() async {
    complaintsList.clear();
    try {
      isLoading = true;
      log(token.toString());
      final response = await ComplaintsRepository().getAllComplaints(
        token: token ?? '',
      );

      if (response.data?.responseCode == 200) {
        List<Data> data = (List.from(response.data?.data as List));

        complaintsList.addAll(data.reversed);
      } else {
        CommonSnackbar(text: "Unable to fetch Complaints").showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }
}
