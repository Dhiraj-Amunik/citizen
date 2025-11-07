import 'dart:async';

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

  bool _isEventLoading = false;
  bool get isEventLoading => _isEventLoading;
  set isEventLoading(bool value) {
    _isEventLoading = value;
    notifyListeners();
  }

  List<model.Events> ongoingEventList = [];
  List<model.Events> upcomingEventList = [];
  List<model.Events> homeEventList = [];
  List<model.Events> pastEventList = [];

  final searchController = TextEditingController();
  Timer? _debounce;

  onSearchChanged(int index) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      switch (index) {
        case 0:
          getEvents(EventFilter.ongoing);
          break;
        case 1:
          getEvents(EventFilter.upcoming);
          break;
        case 2:
          getEvents(EventFilter.past);
          break;
      }
    });
  }

  Future<void> getAllEvents() async {
    isLoading = true;

    try {
      await Future.wait([
        getEvents(EventFilter.ongoing),
        getEvents(EventFilter.upcoming),
        getEvents(EventFilter.past),
      ]);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> getEvents(EventFilter filter, {String? text}) async {
    try {
      if (isEventLoading != true) {
        isEventLoading = true;
      }
      final request = RequestEventModel(
        filter: filter,
        page: 1,
        pageSize: 10,
        search: text ?? searchController.text,
      );
      final response = await EventsRepository().getEvents(
        token,
        model: request,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.events;

        switch (filter) {
          case EventFilter.ongoing:
            ongoingEventList = List<model.Events>.from(data as List);
            break;
          case EventFilter.upcoming:
            upcomingEventList = List<model.Events>.from(data as List);
            homeEventList = upcomingEventList.take(3).toList();
            break;
          case EventFilter.past:
            pastEventList = List<model.Events>.from(data as List);
            break;
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      if (isEventLoading != false) {
        isEventLoading = false;
      }
    }
  }
}

class ShowSearchEventProvider extends ChangeNotifier {
  final Function() clear;

  ShowSearchEventProvider({required this.clear});
  bool _showSearchWidget = false;

  bool get showSearchWidget => _showSearchWidget;

  set showSearchWidget(bool value) {
    _showSearchWidget = value;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
