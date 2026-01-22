import 'dart:async';

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
import 'package:inldsevak/features/events/services/events_repository.dart';

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

  // Track which specific filter is currently loading
  LokVartaFilter? _loadingFilter;
  LokVartaFilter? get loadingFilter => _loadingFilter;
  
  bool isLoadingFilter(LokVartaFilter filter) {
    return _loadingFilter == filter && _isLokVartaLoading;
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
    _isLokVartaLoading = true;
    try {
      // Load all filters in parallel - skip individual loading state management
      await Future.wait([
        getLokVarta(LokVartaFilter.PressRelease, skipLoadingState: true),
        getLokVarta(LokVartaFilter.Interview, skipLoadingState: true),
        getLokVarta(LokVartaFilter.PhotoGallery, skipLoadingState: true),
        getLokVarta(LokVartaFilter.Videos, skipLoadingState: true),
      ]);
    } catch (err, stackTrace) {
      debugPrint("Error in getAllLokVarta: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
      // Ensure loading state is cleared after all parallel calls complete
      _isLokVartaLoading = false;
      _loadingFilter = null;
      notifyListeners();
    }
  }

  bool _showShareIcon = false;
  bool get showShareIcon => _showShareIcon;

  set showShareIcon(bool canShow) {
    if (canShow == false) return;
    _showShareIcon = canShow;
    notifyListeners();
  }

  Future<void> getLokVarta(LokVartaFilter filters, {bool skipLoadingState = false}) async {
    try {
      // Track which filter is loading
      _loadingFilter = filters;
      if (!skipLoadingState && !isLokVartaLoading) {
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
        
        // Handle null or empty data
        var mediaList = data != null ? List<model.Media>.from(data as List) : <model.Media>[];

        // Filter videos to show only published status
        if (filters == LokVartaFilter.Videos) {
          mediaList = mediaList.where((media) {
            return media.status?.toLowerCase() == 'published';
          }).toList();
        }

        // Filter photos to show only published status
        if (filters == LokVartaFilter.PhotoGallery) {
          mediaList = mediaList.where((media) {
            return media.status?.toLowerCase() == 'published';
          }).toList();
        }

        switch (filters) {
          case LokVartaFilter.PressRelease:
            pressReleasesList = mediaList;
            break;
          case LokVartaFilter.PhotoGallery:
            photoLists = mediaList;
            break;
          case LokVartaFilter.Interview:
            interviewsList = mediaList;
            break;
          case LokVartaFilter.Videos:
            videosList = mediaList;
            break;
        }
        // Notify listeners after updating the list
        notifyListeners();
      } else {
        debugPrint("⚠️ getLokVarta failed for ${filters.name}: ${response.data?.message}");
        // Don't clear the list if API call failed - keep existing data if any
        // Only clear if this was the first load attempt
        switch (filters) {
          case LokVartaFilter.PressRelease:
            if (pressReleasesList.isEmpty) {
              pressReleasesList = [];
            }
            break;
          case LokVartaFilter.PhotoGallery:
            if (photoLists.isEmpty) {
              photoLists = [];
            }
            break;
          case LokVartaFilter.Interview:
            if (interviewsList.isEmpty) {
              interviewsList = [];
            }
            break;
          case LokVartaFilter.Videos:
            if (videosList.isEmpty) {
              videosList = [];
            }
            break;
        }
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("🔴 Error in getLokVarta for ${filters.name}: $err");
      debugPrint("Stack Trace: $stackTrace");
      // Don't clear existing data on error, only if list was empty
      switch (filters) {
        case LokVartaFilter.PressRelease:
          if (pressReleasesList.isEmpty) {
            pressReleasesList = [];
          }
          break;
        case LokVartaFilter.PhotoGallery:
          if (photoLists.isEmpty) {
            photoLists = [];
          }
          break;
        case LokVartaFilter.Interview:
          if (interviewsList.isEmpty) {
            interviewsList = [];
          }
          break;
        case LokVartaFilter.Videos:
          if (videosList.isEmpty) {
            videosList = [];
          }
          break;
      }
      notifyListeners();
    } finally {
      // Only clear loading state if this was the filter that was loading and not skipping loading state
      if (!skipLoadingState && _loadingFilter == filters && isLokVartaLoading) {
        _loadingFilter = null;
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

  Future<void> shareEvent(String eventId) async {
    try {
      final response = await EventsRepository().shareEvent(
        token: token,
        eventId: eventId,
      );
      if (response.error != null) {
        debugPrint("Error sharing event: ${response.error?.message}");
      } else if (response.data != null) {
        debugPrint("Event shared successfully: ${response.data}");
      }
    } catch (err, stackTrace) {
      debugPrint("Error in shareEvent: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
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
