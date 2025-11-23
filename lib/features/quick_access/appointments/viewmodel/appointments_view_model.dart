import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';
import 'package:inldsevak/features/quick_access/appointments/services/appointments_repository.dart';

class AppointmentsViewModel extends BaseViewModel {
  @override
  Future<void> onInit() {
    getAppointmentsList();
    return super.onInit();
  }

  String? statusKey;
  String? dateKey;

  List<String> statusItems = [
    "Pending",
    "Approved",
    "Rejected",
    "Completed",
    "Cancelled",
    "Rescheduled",
  ];
  List<String> dateItems = ["Recent", "One Month", "Six Months"];

  List<Appointments> appointmentsList = [];
  List<Appointments> filteredAppointmentsList = [];

  final searchController = TextEditingController();

  setStatus(String status) {
    statusKey = status;
    notifyListeners();
  }

  setDate(String status) {
    dateKey = status;
    notifyListeners();
  }

  Future<void> getAppointmentsList() async {
    try {
      isLoading = true;
      appointmentsList.clear();
      filteredAppointmentsList.clear();
      final response = await AppointmentsRepository().appointments(
        token,
        status: statusKey?.toLowerCase(),
        date: dateKey == "Recent"
            ? 7
            : dateKey == "One Month"
            ? 30
            : dateKey == "Six Months"
            ? 180
            : 0,
      );

      if (response.data?.responseCode == 200) {
        appointmentsList.clear();
        final data = response.data?.data;
        if (data?.appointments?.isNotEmpty == true) {
          appointmentsList = List<Appointments>.from(
            data?.appointments as List,
          );
          filteredAppointmentsList.addAll(appointmentsList);
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  filterList() {
    filteredAppointmentsList.clear();
    filteredAppointmentsList.addAll(
      appointmentsList.where((appointment) {
        return _matchesSearch(appointment);
      }),
    );

    notifyListeners();
  }

  bool _matchesSearch(Appointments appointment) {
    final searchQuery = searchController.text.trim().toLowerCase();
    return appointment.purpose?.toLowerCase().contains(searchQuery) == true ||
        appointment.reason?.toLowerCase().contains(searchQuery) == true;
  }
}
