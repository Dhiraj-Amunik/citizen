import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/models/request/pagination_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:quickalert/quickalert.dart';

class MyHelpRequestsViewModel extends BaseViewModel {
  @override
  Future<void> onInit() async {
    scrollController.addListener(_scrollListener);
    await onRefresh();
    return super.onInit();
  }

  List<model.FinancialRequest> myWallOFHelpLists = [];
  List<model.FinancialRequest> _filteredList = [];
  List<model.FinancialRequest> get filteredList => _filteredList;

  final WallOfHelpRepository repository = WallOfHelpRepository();

  // Pagination
  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();
  bool showSearchWidget = false;

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      loadMoreData();

      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent /
      //       1.5,
      //   duration: Duration(milliseconds: 300),
      //   curve: Curves.easeIn,
      // );
    }
  }

  void loadMoreData() async {
    if (isLoading || _isScrollLoading) {
      return; // Don't load more data if already loading
    }
    if (!_isLastPage) {
      _currentPage++;
      getMyWallOfHelpList();
    }
  }

  Future<void> onRefresh() async {
    _currentPage = 1;
    _isLastPage = false;
    await getMyWallOfHelpList();
  }

  int _currentPage = 1;
  bool _isLastPage = false;

  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  set isScrollLoading(bool value) {
    _isScrollLoading = value;
    notifyListeners();
  }

  Future<void> getMyWallOfHelpList() async {
    if (_currentPage == 1) {
      myWallOFHelpLists.clear();
      isLoading = true;
      _applySearchFilter(searchController.text);
    } else {
      isScrollLoading = true;
    }
    try {
      final paginationModel = PaginationModel(page: _currentPage);
      final response = await repository.getMyWallOFHelp(
        token: token,
        model: paginationModel,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.financialRequest ?? [];
        if (data.isEmpty) {
          _isLastPage = true;
        } else {
          myWallOFHelpLists.addAll(
            List<model.FinancialRequest>.from(data),
          );
        }
        _applySearchFilter(searchController.text);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isScrollLoading = false;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> closeMyFinancialHelp(model.FinancialRequest request) async {
    try {
      isLoading = true;
      final index = myWallOFHelpLists.indexWhere(
        (element) => element.sId == request.sId,
      );
      if (index == -1) {
        return;
      }
      final response = await repository.closeFinancialHelp(
        token: token,
        id: myWallOFHelpLists[index].sId!,
      );

      if (response.data?.responseCode == 200) {
        onRefresh();
        await CommonSnackbar(
          text: response.data?.message ?? "Request Closed Successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Failed to close my request",
        ).showAnimatedDialog(type: QuickAlertType.success);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  void toggleSearch() {
    if (showSearchWidget) {
      hideSearch();
    } else {
      showSearchWidget = true;
      notifyListeners();
    }
  }

  void hideSearch() {
    if (!showSearchWidget) return;
    showSearchWidget = false;
    searchController.clear();
    _applySearchFilter("");
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _applySearchFilter("");
  }

  void onSearchChanged(String query) {
    _applySearchFilter(query);
  }

  void _applySearchFilter(String query) {
    if (query.trim().isEmpty) {
      _filteredList = List.from(myWallOFHelpLists);
    } else {
      final lowerQuery = query.trim().toLowerCase();
      _filteredList = myWallOFHelpLists.where((request) {
        final title = request.title?.toLowerCase() ?? "";
        final status = request.status?.toLowerCase() ?? "";
        final helpType = request.typeOfHelp?.name?.toLowerCase() ?? "";
        final requester = request.name?.toLowerCase() ?? "";
        return title.contains(lowerQuery) ||
            status.contains(lowerQuery) ||
            helpType.contains(lowerQuery) ||
            requester.contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
