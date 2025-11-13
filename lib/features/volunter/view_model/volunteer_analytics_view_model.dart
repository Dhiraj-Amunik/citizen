import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/volunter/models/response/volunteer_analytics_response_model.dart';
import 'package:inldsevak/features/volunter/services/volunteer_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';

class VolunteerAnalyticsViewModel extends BaseViewModel {
  VolunteerAnalyticsViewModel() {
    _repository = VolunteerRepository();
  }

  late final VolunteerRepository _repository;

  VolunteerAnalyticsData? _analytics;
  VolunteerAnalyticsData? get analytics => _analytics;

  List<TopVolunteer> get topVolunteers => _analytics?.topVolunteers ?? [];
  MyVolunteerAnalytics? get myAnalytics => _analytics?.myAnalytics;
  List<VolunteerEvent> get attendedEvents => _analytics?.attendedEvents ?? [];
  List<VolunteerEvent> get upcomingEvents => _analytics?.upcomingEvents ?? [];

  String get lastMonthLabel =>
      myAnalytics?.lastMonth?.trim().isNotEmpty == true
          ? myAnalytics!.lastMonth!
          : '-';

  bool get hasData => _analytics != null;

  @override
  Future<void> onInit() async {
    await fetchVolunteerAnalytics();
  }

  Future<void> fetchVolunteerAnalytics() async {
    try {
      isLoading = true;
      final response =
          await _repository.getVolunteerAnalytics(token: token ?? "");

      if (response.error != null) {
        CommonSnackbar(text: response.error?.message).showToast();
        return;
      }

      final data = response.data;
      if (data?.responseCode == 200 && data?.data != null) {
        _analytics = data!.data;
      } else {
        CommonSnackbar(
          text: data?.message ?? "Unable to fetch volunteer analytics",
        ).showToast();
      }
    } catch (error, stackTrace) {
      debugPrint("Volunteer analytics error: $error");
      debugPrint(stackTrace.toString());
      CommonSnackbar(text: "Something went wrong, please try again.")
          .showToast();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> attendEvent(String eventId) async {
    final trimmedEventId = eventId.trim();
    if (trimmedEventId.isEmpty) {
      await CommonSnackbar(
        text: "Invalid event QR code.",
      ).showAnimatedDialog(type: QuickAlertType.warning);
      return false;
    }

    try {
      final response = await _repository.attendEvent(
        token: token,
        eventId: trimmedEventId,
      );

      if (response.error != null) {
        final rawMessage = response.error?.message ?? "";
        final displayMessage = rawMessage.toLowerCase().contains("server error")
            ? "Event not found."
            : rawMessage.isNotEmpty
                ? rawMessage
                : "Event not found.";
        await CommonSnackbar(
          text: displayMessage,
        ).showAnimatedDialog(type: QuickAlertType.error);
        return false;
      }

      final data = response.data;
      if (data?.responseCode == 200) {
        await CommonSnackbar(
          text: data?.message ?? "Event attended successfully.",
        ).showAnimatedDialog(type: QuickAlertType.success);
        await fetchVolunteerAnalytics();
        return true;
      }

      await CommonSnackbar(
        text: data?.message ?? "Event not found.",
      ).showAnimatedDialog(type: QuickAlertType.warning);
      return false;
    } catch (error, stackTrace) {
      debugPrint("Attend event error: $error");
      debugPrint(stackTrace.toString());
      await CommonSnackbar(
        text: "Event not found.",
      ).showAnimatedDialog(type: QuickAlertType.error);
      return false;
    }
  }
}

