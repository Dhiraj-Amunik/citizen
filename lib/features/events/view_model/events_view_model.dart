import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/events/model/events_model.dart' as model;
import 'package:inldsevak/features/events/model/request_event_model.dart';
import 'package:inldsevak/features/events/services/events_repository.dart';

class EventsViewModel extends BaseViewModel {
  @override
  Future<void> onInit() async {
    await getAllEvents();
    return super.onInit();
  }

  List<model.Events> ongoingEventList = [];
  List<model.Events> upcomingEventList = [];
  List<model.Events> homeEventList = [];
  List<model.Events> pastEventList = [];

  Future<void> getAllEvents() async {
    isLoading = true;

    try {
      await Future.wait([
        getEvents(EventFilter.ongoing),
        getEvents(EventFilter.upcoming),
        getEvents(EventFilter.upcoming, pageSize: 3),
        getEvents(EventFilter.past),
      ]);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> getEvents(EventFilter filter, {int? pageSize}) async {
    try {
      final request = RequestEventModel(
        filter: filter,
        page: 1,
        pageSize: pageSize,
      );
      final response = await EventsRepository().getEvents(
        token,
        model: request,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.events;

        if (request.pageSize != null) {
          homeEventList = List<model.Events>.from(data as List);
          return;
        }
        if (data?.isNotEmpty == true) {
          switch (filter) {
            case EventFilter.ongoing:
              ongoingEventList = List<model.Events>.from(data as List);
              break;
            case EventFilter.upcoming:
              upcomingEventList = List<model.Events>.from(data as List);
              break;
            case EventFilter.past:
              pastEventList = List<model.Events>.from(data as List);
              break;
          }
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }
}
