import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/home/services/dashboard_repository.dart';
import 'package:inldsevak/features/volunter/models/response/volunteer_analytics_response_model.dart';
import 'package:inldsevak/features/volunter/services/volunteer_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';

class VolunteerAnalyticsViewModel extends BaseViewModel {
  VolunteerAnalyticsViewModel() {
    _repository = VolunteerRepository();
    _dashboardRepository = DashboardRepository();
  }

  late final VolunteerRepository _repository;
  late final DashboardRepository _dashboardRepository;

  VolunteerAnalyticsData? _analytics;
  VolunteerAnalyticsData? get analytics => _analytics;

  bool? _isVolunteer;
  String? _volunteerStatus;
  bool _hasFetchedStatus = false;
  
  bool get hasFetchedStatus => _hasFetchedStatus;
  
  bool get canApply {
    if (_isVolunteer == true) return false;
    final status = _volunteerStatus?.toLowerCase().trim();
    if (status == null) return true;
    // Cannot apply if status is pending, approved, or rejected
    return status != 'pending' && status != 'approved' && status != 'rejected';
  }
  
  String? get statusMessage {
    if (_isVolunteer == true || _volunteerStatus?.toLowerCase().trim() == 'approved') {
      return "You are a volunteer";
    }
    if (_volunteerStatus?.toLowerCase().trim() == 'pending') {
      return "Volunteer request is pending";
    }
    if (_volunteerStatus?.toLowerCase().trim() == 'rejected') {
      return "Volunteer request is rejected";
    }
    return null;
  }

  List<TopVolunteer> get topVolunteers => _analytics?.topVolunteers ?? [];
  MyVolunteerAnalytics? get myAnalytics => _analytics?.myAnalytics;
  List<VolunteerEvent> get attendedEvents => _analytics?.attendedEvents ?? [];
  List<VolunteerEvent> get upcomingEvents => _analytics?.upcomingEvents ?? [];
  int? get highestInviteReward => _analytics?.highestInviteReward;
  List<TopReferralUser> get topReferralUsers => _analytics?.topReferralUsers ?? [];
  List<ReferralGraphItem> get referralGraph => _analytics?.referralGraph ?? [];
  int? get highestShareEvent => _analytics?.highestShareEvent;
  List<TopShareEventUser> get topShareEventUsers => _analytics?.topShareEventUsers ?? [];
  List<ShareEventGraphItem> get shareEventGraph => _analytics?.shareEventGraph ?? [];

  String get lastMonthLabel =>
      myAnalytics?.lastMonth?.trim().isNotEmpty == true
          ? myAnalytics!.lastMonth!
          : '-';

  bool get hasData => _analytics != null;

  @override
  Future<void> onInit() async {
    await Future.wait([
      fetchVolunteerStatus(),
      fetchVolunteerAnalytics(),
    ]);
    // Notify listeners after both fetches complete
    notifyListeners();
  }

  Future<void> fetchVolunteerStatus() async {
    try {
      final response = await _dashboardRepository.fetchDashboard(
        token: token,
      );

      if (response.error != null) {
        debugPrint("Error fetching volunteer status: ${response.error?.message}");
        return;
      }

      final data = response.data;
      if (data?.responseCode == 200 && data?.data != null) {
        _isVolunteer = data!.data!.isVolunteer;
        _volunteerStatus = data.data!.volunteerStatus;
        _hasFetchedStatus = true;
        notifyListeners();
      } else {
        _hasFetchedStatus = true; // Mark as fetched even if response is invalid
      }
    } catch (error, stackTrace) {
      debugPrint("Volunteer status error: $error");
      debugPrint(stackTrace.toString());
      _hasFetchedStatus = true; // Mark as fetched even on error
    }
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
        
        // Debug logging for analytics data
        debugPrint("📊 Volunteer Analytics Fetched:");
        debugPrint("  - Referred Users: ${_analytics?.myAnalytics?.referedUsers}");
        debugPrint("  - Attended Events: ${_analytics?.myAnalytics?.attendedEvents}");
        debugPrint("  - Shared Events: ${_analytics?.myAnalytics?.sharedEvents}");
        debugPrint("  - Total Shares: ${_analytics?.myAnalytics?.totalShares}");
        debugPrint("  - Total Coins: ${_analytics?.myAnalytics?.totalCoins}");
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

  Future<void> refresh() async {
    await Future.wait([
      fetchVolunteerStatus(),
      fetchVolunteerAnalytics(),
    ]);
  }

  bool get isVolunteerApproved {
    final status = _volunteerStatus?.toLowerCase().trim();
    return _isVolunteer == true || status == 'approved';
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

