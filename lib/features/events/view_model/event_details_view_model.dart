import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/events/model/event_details_model.dart'
    as model;
import 'package:inldsevak/features/events/model/request_details_event_model.dart';
import 'package:inldsevak/features/events/services/events_repository.dart';

class EventDetailsViewModel extends BaseViewModel {
  bool _showShareIcon = false;
  bool get showShareIcon => _showShareIcon;

  set showShareIcon(bool canShow) {
    _showShareIcon = canShow;
    notifyListeners();
  }

  Future<model.Data?> getEvents({
    required RequestEventDetailsModel eventModel,
  }) async {
    await Future.delayed(Duration(seconds: 2));
    try {
      isLoading = true;
      final response = await EventsRepository().getEventDetails(
        token,
        model: eventModel,
      );

      if (response.data?.responseCode == 200) {
        return response.data?.data;
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
    return null;
  }
}
