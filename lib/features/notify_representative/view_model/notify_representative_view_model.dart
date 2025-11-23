import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/notify_representative/model/request/nr_pagination_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';
import 'package:inldsevak/features/notify_representative/services/notify_repository.dart';

class NotifyRepresentativeViewModel extends BaseViewModel {
  final _repository = NotifyRepository();

  @override
  Future<void> onInit() {
    recentScrollController.addListener(_recentScrollListener);
    pastScrollController.addListener(_pastScrollListener);
    Future.wait([
      getNotifyFilters(),
      getAllNotifyData(),
    ]);
    return super.onInit();
  }

  // Filters
  NotifyFiltersData? filtersData;
  ConstituencyFilter? selectedConstituency;
  MlaFilter? selectedMla;
  String? selectedDistrict;
  String? selectedMandal;
  String? selectedVillage;

  Future<void> getNotifyFilters() async {
    try {
      final response = await _repository.getNotifyFilters(token: token);
      if (response.data?.responseCode == 200) {
        filtersData = response.data?.data;
        notifyListeners();
      } else {
        CommonSnackbar(
          text: response.data?.message ?? 'Unable to fetch filters',
        ).showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error fetching filters: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  void setConstituency(ConstituencyFilter? constituency) {
    selectedConstituency = constituency;
    selectedMla = null; // Reset MLA when constituency changes
    notifyListeners();
    _applyFilters();
  }

  void setMla(MlaFilter? mla) {
    selectedMla = mla;
    notifyListeners();
    _applyFilters();
  }

  void setDistrict(String? district) {
    selectedDistrict = district;
    notifyListeners();
    _applyFilters();
  }

  void setMandal(String? mandal) {
    selectedMandal = mandal;
    notifyListeners();
    _applyFilters();
  }

  void setVillage(String? village) {
    selectedVillage = village;
    notifyListeners();
    _applyFilters();
  }

  void clearFilters() {
    selectedConstituency = null;
    selectedMla = null;
    selectedDistrict = null;
    selectedMandal = null;
    selectedVillage = null;
    notifyListeners();
    _applyFilters();
  }

  void _applyFilters() {
    onRecentRefresh();
    onPastRefresh();
  }

  Future<void> getAllNotifyData() async {
    isLoading = true;

    try {
      await Future.wait([
        getNotifyLists(NotifyReprFilter.recent),
        getNotifyLists(NotifyReprFilter.past),
      ]);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  final searchController = TextEditingController();
  Timer? _debounce;

  onSearchChanged(int tab) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (tab == 0) {
        onRecentRefresh();
      } else {
        onPastRefresh();
      }
    });
  }

  // Pagination

  final ScrollController recentScrollController = ScrollController();
  final ScrollController pastScrollController = ScrollController();

  List<NotifyRepresentative> recentNotifyLists = [];
  List<NotifyRepresentative> pastNotifyLists = [];

  void _recentScrollListener() {
    if (recentScrollController.position.pixels >=
        recentScrollController.position.maxScrollExtent * 0.8) {
      loadRecentMoreData();
    }
  }

  void _pastScrollListener() {
    if (pastScrollController.position.pixels >=
        pastScrollController.position.maxScrollExtent * 0.8) {
      loadPastMoreData();
    }
  }

  void loadRecentMoreData() async {
    if (isLoading || _isScrollLoading) {
      return;
    }
    if (!_recentIsLastPage) {
      _recentCurrentPage++;
      getNotifyLists(NotifyReprFilter.recent);
    }
  }

  void loadPastMoreData() async {
    if (isLoading || _isScrollLoading) {
      return;
    }
    if (!_pastIsLastPage) {
      _pastCurrentPage++;
      getNotifyLists(NotifyReprFilter.past);
    }
  }

  onRecentRefresh() {
    _recentCurrentPage = 1;
    _recentIsLastPage = false;
    recentNotifyLists.clear(); // Ensure list is cleared before refresh
    getNotifyLists(NotifyReprFilter.recent);
  }

  onPastRefresh() {
    _pastCurrentPage = 1;
    _pastIsLastPage = false;
    pastNotifyLists.clear(); // Ensure list is cleared before refresh
    getNotifyLists(NotifyReprFilter.past);
  }

  int _recentCurrentPage = 1;
  int _pastCurrentPage = 1;
  bool _recentIsLastPage = false;
  bool _pastIsLastPage = false;

  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  set isScrollLoading(bool value) {
    _isScrollLoading = value;
    notifyListeners();
  }

  Future<void> getNotifyLists(NotifyReprFilter filter) async {
    switch (filter) {
      case NotifyReprFilter.recent:
        if (_recentCurrentPage == 1) {
          recentNotifyLists.clear();
          isLoading = true;
        } else {
          isScrollLoading = true;
        }
        break;

      case NotifyReprFilter.past:
        if (_pastCurrentPage == 1) {
          pastNotifyLists.clear();
          isLoading = true;
        } else {
          isScrollLoading = true;
        }
        break;
    }

    try {
      // Convert single selections to arrays as API expects
      final paginationModel = NotifyReprPaginationModel(
        filter: filter,
        page: NotifyReprFilter.recent == filter
            ? _recentCurrentPage
            : _pastCurrentPage,
        search: searchController.text.isEmpty ? null : searchController.text,
        constituencies: selectedConstituency?.sId != null 
            ? [selectedConstituency!.sId!] 
            : null,
        mlaIds: selectedMla?.sId != null 
            ? [selectedMla!.sId!] 
            : null,
        districts: selectedDistrict != null && selectedDistrict!.isNotEmpty
            ? [selectedDistrict!]
            : null,
        mandals: selectedMandal != null && selectedMandal!.isNotEmpty
            ? [selectedMandal!]
            : null,
        villages: selectedVillage != null && selectedVillage!.isNotEmpty
            ? [selectedVillage!]
            : null,
        sortBy: "-1", // Default to descending (newest first)
      );
      final response = await _repository.getNotifyRepresentative(
        token: token,
        model: paginationModel,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.notifyRepresentative;

        if (data?.isEmpty == true) {
          // Set the appropriate last page flag
          if (filter == NotifyReprFilter.recent) {
            _recentIsLastPage = true;
          } else {
            _pastIsLastPage = true;
          }
          return;
        }
        if (data?.isNotEmpty == true) {
          // Convert to list and filter out duplicates
          final newItems = List<NotifyRepresentative>.from(data as List);
          final pageSize = response.data?.data?.pageSize ?? 20;
          
          switch (filter) {
            case NotifyReprFilter.recent:
              // Filter out duplicates based on sId before adding
              final existingIds = recentNotifyLists.map((e) => e.sId).toSet();
              final uniqueItems = newItems.where((item) => !existingIds.contains(item.sId)).toList();
              recentNotifyLists.addAll(uniqueItems);
              // Update last page flag - if we got less items than page size, we're on the last page
              if (newItems.length < pageSize) {
                _recentIsLastPage = true;
              }
              break;

            case NotifyReprFilter.past:
              // Filter out duplicates based on sId before adding
              final existingIds = pastNotifyLists.map((e) => e.sId).toSet();
              final uniqueItems = newItems.where((item) => !existingIds.contains(item.sId)).toList();
              pastNotifyLists.addAll(uniqueItems);
              // Update last page flag - if we got less items than page size, we're on the last page
              if (newItems.length < pageSize) {
                _pastIsLastPage = true;
              }
              break;
          }
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isScrollLoading = false;
      isLoading = false;
    }
  }

  Future<void> deleteNotify(NotifyRepresentative? data) async {
    try {
      final response = await _repository.deleteNotify(
        token: token,
        id: data?.sId ?? "",
      );

      if (response.data?.responseCode == 200) {
        recentNotifyLists.remove(data);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isScrollLoading = false;
      isLoading = false;
    }
  }
}

class ShowSearchNotifyProvider extends ChangeNotifier {
  bool _showSearchWidget = false;

  bool get showSearchWidget => _showSearchWidget;

  set showSearchWidget(bool value) {
    _showSearchWidget = value;
    notifyListeners();
  }
}
