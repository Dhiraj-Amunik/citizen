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
  List<complaint.Data> filteredComplaintsList = [];

  final searchController = TextEditingController();

  Future<void> getComplaints() async {
    try {
      isLoading = true;
      log(token.toString());
      final response = await ComplaintsRepository().getAllComplaints(
        token: token ?? '',
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        filteredComplaintsList.clear();
        complaintsList = List<complaint.Data>.from(data as List);
        filteredComplaintsList.addAll(complaintsList);
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

  filterList() {
    filteredComplaintsList.clear();
    filteredComplaintsList.addAll(
      complaintsList.where((complaint) {
        return _matchesSearch(complaint);
      }),
    );

    notifyListeners();
  }

  bool _matchesSearch(complaint.Data complaint) {
    final searchQuery = searchController.text.trim().toLowerCase();
    return complaint.messages?.first.subject?.toLowerCase().contains(
              searchQuery,
            ) ==
            true ||
        complaint.messages?.first.body?.toLowerCase().contains(searchQuery) ==
            true;
  }
}
