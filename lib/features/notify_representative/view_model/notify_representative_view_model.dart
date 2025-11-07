import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/notify_representative/model/request/nr_pagination_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';
import 'package:inldsevak/features/notify_representative/services/notify_repository.dart';

class NotifyRepresentativeViewModel extends BaseViewModel {
  final _repository = NotifyRepository();

  @override
  Future<void> onInit() {
    recentScrollController.addListener(_recentScrollListener);
    pastScrollController.addListener(_pastScrollListener);
    getAllNotifyData();
    return super.onInit();
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
    if (!_isLastPage) {
      _recentCurrentPage++;
      getNotifyLists(NotifyReprFilter.recent);
    }
  }

  void loadPastMoreData() async {
    if (isLoading || _isScrollLoading) {
      return;
    }
    if (!_isLastPage) {
      _pastCurrentPage++;
      getNotifyLists(NotifyReprFilter.past);
    }
  }

  onRecentRefresh() {
    _recentCurrentPage = 1;
    _isLastPage = false;
    getNotifyLists(NotifyReprFilter.recent);
  }

  onPastRefresh() {
    _pastCurrentPage = 1;
    _isLastPage = false;
    getNotifyLists(NotifyReprFilter.past);
  }

  int _recentCurrentPage = 1;
  int _pastCurrentPage = 1;
  bool _isLastPage = false;

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
      final paginationModel = NotifyReprPaginationModel(
        filter: filter,
        page: NotifyReprFilter.recent == filter
            ? _recentCurrentPage
            : _pastCurrentPage,
        search: searchController.text,
      );
      final response = await _repository.getNotifyRepresentative(
        token: token,
        model: paginationModel,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.notifyRepresentative;

        if (data?.isEmpty == true) {
          _isLastPage = true;
          return;
        }
        if (data?.isNotEmpty == true) {
          if (data?.isNotEmpty == true) {
            switch (filter) {
              case NotifyReprFilter.recent:
                recentNotifyLists.addAll(List.from(data as List));
                break;

              case NotifyReprFilter.past:
                pastNotifyLists.addAll(List.from(data as List));
                break;
            }
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
