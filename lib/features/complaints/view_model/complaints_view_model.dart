import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart'
    as complaint;
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';

class ComplaintsViewModel extends BaseViewModel {
  ComplaintsViewModel() {
    init();
  }

  void init() async {
    await initialize();
    await getComplaints();
  }

  List<complaint.Data> complaintsList = [];

  Future<void> getComplaints() async {
    try {
      isLoading = true;
      log(token.toString());
      final response = await ComplaintsRepository().getAllComplaints(
        token: token ?? '',
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        complaintsList = List<complaint.Data>.from(data as List);
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
