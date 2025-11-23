import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/request/my_complaint_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart'
    as complaint;
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart'
    as departments;

class ComplaintsViewModel extends BaseViewModel {
  ComplaintsViewModel() {
    init();
  }

  Timer? _autoRefreshTimer;

  void init() async {
    await initialize();
    await Future.wait([getComplaints(), getDepartments()]);
    _startAutoRefresh();
  }

  //Filters

  final fromDate = TextEditingController();
  final toDate = TextEditingController();

  List<String>? selectedStatusList = [];
  departments.Data? departmentKey;
  String? date;
  String? fromDateCompany;
  String? toDateCompany;

  List<String> complaintFilterList = [
    "Pending",
    "In-progress",
    "Resolved",
    "Closed",
    "Escalated",
  ];

  List<complaint.Data> complaintsList = [];
  List<complaint.Data> filteredComplaintsList = [];
  List<departments.Data> departmentLists = [];

  final searchController = TextEditingController();

  setStatus(String status) {
    if (selectedStatusList?.contains(status) == true) {
      selectedStatusList?.remove(status);
    } else {
      selectedStatusList?.add(status);
    }
    notifyListeners();
  }

  Future<void> getComplaints({
    bool showLoader = true,
    bool preserveSearch = false,
  }) async {
    try {
      if (showLoader) {
        isLoading = true;
      }
      if (!preserveSearch) {
        searchController.clear();
      }
      log(token.toString());

      final filters = MyComplaintRequestModel(
        status: selectedStatusList,
        departmentId: departmentKey?.sId,
        date: fromDateCompany != null || toDateCompany != null ? "custom" : "",
        startDate: fromDateCompany ?? toDateCompany,
        endDate: toDateCompany ?? fromDateCompany,
      );
      final response = await ComplaintsRepository().getAllComplaints(
        token: token ?? '',
        filters: filters,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        filteredComplaintsList.clear();
        complaintsList = List<complaint.Data>.from(data as List);
        if (searchController.text.trim().isNotEmpty) {
          filterList();
        } else {
          filteredComplaintsList.addAll(complaintsList);
          notifyListeners();
        }
      } else {
        CommonSnackbar(text: "Unable to fetch Complaints").showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      if (showLoader) {
        isLoading = false;
      }
    }
  }

  Future<void> getDepartments() async {
    try {
      final response = await ComplaintsRepository().getDepartments(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(text: "No departments found").showToast();
        } else {
          departmentLists = List<departments.Data>.from(data as List);
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
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

  void determineSelectedFilter(String type) {
    final now = DateTime.now();
    final week = now.subtract(const Duration(days: 6));
    final month = now.subtract(const Duration(days: 30));

    switch (type) {
      case "today":
        fromDateCompany = now.toString().toYyyyMmDd();
        fromDate.text = fromDateCompany?.toDdMmYyyy() ?? "";
        toDate.text = fromDate.text;
        toDateCompany = fromDateCompany;
        break;
      case "week":
        fromDateCompany = week.toString().toYyyyMmDd();
        toDateCompany = now.toString().toYyyyMmDd();
        fromDate.text = fromDateCompany?.toDdMmYyyy() ?? "";
        toDate.text = toDateCompany?.toDdMmYyyy() ?? "";
        break;
      case "month":
        fromDateCompany = month.toString().toYyyyMmDd();
        toDateCompany = now.toString().toYyyyMmDd();
        fromDate.text = fromDateCompany?.toDdMmYyyy() ?? "";
        toDate.text = toDateCompany?.toDdMmYyyy() ?? "";
        break;
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => getComplaints(showLoader: false, preserveSearch: true),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    searchController.dispose();
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }
}
