import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/events/model/request_event_model.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/services/lok_varta_repository.dart';
import 'package:inldsevak/features/lok_varta/model/mla_details_model.dart'
    as mladetails;

class LokVartaViewModel extends BaseViewModel {
  @override
  Future<void> onInit() async {
    await getMlaDetails();
    await getAllLokVarta();
    return super.onInit();
  }

  List<model.Media> pressReleasesList = [];
  List<model.Media> interviewsList = [];
  List<model.Media> articlesList = [];
  List<model.Media> videosList = [];
  List<model.Media> photoLists = [];

  mladetails.Mla? mlaModel;

  bool _isLokVartaLoading = false;
  bool get isLokVartaLoading => _isLokVartaLoading;
  set isLokVartaLoading(bool value) {
    _isLokVartaLoading = value;
    notifyListeners();
  }

  final searchController = TextEditingController();
  Timer? _debounce;

  onSearchChanged(int index, Function(EventFilter type, {String? text}) event) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      switch (index) {
        case 0:
          event(EventFilter.upcoming, text: searchController.text);
          break;
        case 1:
          event(EventFilter.ongoing, text: searchController.text);
          break;
        case 2:
          getLokVarta(LokVartaFilter.PressRelease);
          break;
        case 3:
          getLokVarta(LokVartaFilter.Interview);
          break;
        case 4:
          getLokVarta(LokVartaFilter.Videos);
          break;
        case 5:
          getLokVarta(LokVartaFilter.PhotoGallery);
          break;
      }
    });
  }

  Future<void> getAllLokVarta() async {
    isLoading = true;
    try {
      await Future.wait([
        getLokVarta(LokVartaFilter.PressRelease),
        getLokVarta(LokVartaFilter.Interview),
        getLokVarta(LokVartaFilter.PhotoGallery),
        getLokVarta(LokVartaFilter.Videos),
      ]);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  bool _showShareIcon = false;
  bool get showShareIcon => _showShareIcon;

  set showShareIcon(bool canShow) {
    if (canShow == false) return;
    _showShareIcon = canShow;
    notifyListeners();
  }

  Future<void> getLokVarta(LokVartaFilter filters) async {
    try {
      if (isLokVartaLoading != true) {
        isLokVartaLoading = true;
      }
      final request = RequestLokVartaModel(
        filter: filters,
        search: searchController.text,
      );
      final response = await LokVartaRepository().getLokVarta(
        token,
        model: request,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.media;

        switch (filters) {
          case LokVartaFilter.PressRelease:
            pressReleasesList = List<model.Media>.from(data as List);
            break;
          case LokVartaFilter.PhotoGallery:
            photoLists = List<model.Media>.from(data as List);
            break;
          case LokVartaFilter.Interview:
            interviewsList = List<model.Media>.from(data as List);
            break;
          case LokVartaFilter.Videos:
            videosList = List<model.Media>.from(data as List);
            break;
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      if (isLokVartaLoading != false) {
        isLokVartaLoading = false;
      }
    }
  }

  Future<void> getMlaDetails() async {
    try {
      final response = await LokVartaRepository().getUserMlaDetails(token);

      if (response.data?.responseCode == 200) {
        mlaModel = response.data?.data?.mla;
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<model.Media?> getLokVartaDetails(String id) async {
    try {
      _showShareIcon = false;
      final response = await LokVartaRepository().getlokVartaDetails(
        token: token,
        id: id,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        showShareIcon = data?.url?.showDataNull ?? false;
        return data;
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return null;
  }
}

class ShowSearchLokVartaProvider extends ChangeNotifier {
  final Function() clear;

  ShowSearchLokVartaProvider({required this.clear});
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
