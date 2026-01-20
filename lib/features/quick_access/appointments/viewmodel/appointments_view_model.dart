import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';
import 'package:inldsevak/features/quick_access/appointments/services/appointments_repository.dart';
import 'package:inldsevak/l10n/general_stream.dart';

class AppointmentsViewModel extends BaseViewModel {
  @override
  Future<void> onInit() async {
    // Don't call getAppointmentsList here - let the view handle it after initialization
    await super.onInit();
  }

  String? statusKey;
  String? dateKey;

  List<String> statusItems = [
    "Pending",
    "Approved",
    "Rejected",
    "Cancelled",
    "Rescheduled",
  ];
  List<String> dateItems = ["Recent", "One Month", "Six Months"];

  List<Appointments> appointmentsList = [];
  List<Appointments> filteredAppointmentsList = [];
  bool _hasInitialLoadCompleted = false;

  final searchController = TextEditingController();
  
  bool get hasInitialLoadCompleted => _hasInitialLoadCompleted;

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
      // Ensure token is available before making API call
      if (token == null || token!.isEmpty) {
        // Wait a bit for token to be loaded
        int retries = 0;
        while ((token == null || token!.isEmpty) && retries < 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          retries++;
        }
        
        // If still no token, return early
        if (token == null || token!.isEmpty) {
          debugPrint("Token not available for appointments API call");
          _hasInitialLoadCompleted = true;
          isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      isLoading = true;
      notifyListeners();
      
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
        final data = response.data?.data;
        if (data?.appointments?.isNotEmpty == true) {
          // Get raw appointments from API
          final rawAppointments = List<Appointments>.from(
            data?.appointments as List,
          );
          
          // Translate appointments if app is in Hindi
          final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
          if (isHindiLocale) {
            // Translate all appointments before storing
            appointmentsList = await _translateAppointments(rawAppointments);
          } else {
            // Store as-is if app is in English
            appointmentsList = rawAppointments;
          }
          
          // Only update filtered list after successfully loading data
          filteredAppointmentsList.clear();
          filteredAppointmentsList.addAll(appointmentsList);
        } else {
          // Only clear if we got a successful response with no data
          appointmentsList.clear();
          filteredAppointmentsList.clear();
        }
        _hasInitialLoadCompleted = true;
        notifyListeners();
      } else {
        // If response code is not 200, mark as completed but keep existing data
        _hasInitialLoadCompleted = true;
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      _hasInitialLoadCompleted = true;
    } finally {
      isLoading = false;
      notifyListeners();
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

  /// Translate appointments based on app language
  /// Translates purpose and reason fields when app is in Hindi
  Future<List<Appointments>> _translateAppointments(List<Appointments> rawAppointments) async {
    final translatedAppointments = <Appointments>[];
    
    // Translate all appointments in parallel for better performance
    final translationFutures = rawAppointments.map((appointment) async {
      // Translate purpose and reason fields
      final translatedPurpose = await TranslationHelper.translateText(
        appointment.purpose,
        force: true, // Force translation based on locale (English -> Hindi)
      );
      
      final translatedReason = await TranslationHelper.translateText(
        appointment.reason,
        force: true, // Force translation based on locale (English -> Hindi)
      );
      
      // Create new appointment with translated fields
      return Appointments(
        sId: appointment.sId,
        mla: appointment.mla,
        mlaObject: appointment.mlaObject,
        bookFor: appointment.bookFor,
        name: appointment.name,
        profileImage: appointment.profileImage,
        memberShipId: appointment.memberShipId,
        phone: appointment.phone,
        date: appointment.date,
        rescheduledDate: appointment.rescheduledDate,
        timeSlot: appointment.timeSlot,
        purpose: translatedPurpose,
        reason: translatedReason,
        documents: appointment.documents,
        user: appointment.user,
        partyMember: appointment.partyMember,
        priority: appointment.priority,
        isPartyMember: appointment.isPartyMember,
        status: appointment.status,
        approvedBy: appointment.approvedBy,
        isActive: appointment.isActive,
        isDeleted: appointment.isDeleted,
        createdAt: appointment.createdAt,
        updatedAt: appointment.updatedAt,
        iV: appointment.iV,
      );
    }).toList();
    
    // Wait for all translations to complete
    translatedAppointments.addAll(await Future.wait(translationFutures));
    
    return translatedAppointments;
  }

  bool _matchesSearch(Appointments appointment) {
    final searchQuery = searchController.text.trim().toLowerCase();
    return appointment.purpose?.toLowerCase().contains(searchQuery) == true ||
        appointment.reason?.toLowerCase().contains(searchQuery) == true;
  }
}
