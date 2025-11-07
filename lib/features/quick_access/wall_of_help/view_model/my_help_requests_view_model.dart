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
  Future<void> onInit() {
    scrollController.addListener(_scrollListener);
    onRefresh();
    return super.onInit();
  }

  List<model.FinancialRequest> myWallOFHelpLists = [];
  final WallOfHelpRepository repository = WallOfHelpRepository();

  // Pagination

  final ScrollController scrollController = ScrollController();

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

  onRefresh() {
    _currentPage = 1;
    _isLastPage = false;
    getMyWallOfHelpList();
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
        final data = response.data?.data?.financialRequest;

        if (data?.isEmpty == true) {
          _isLastPage = true;
          return;
        }
        if (data?.isNotEmpty == true) {
          myWallOFHelpLists.addAll(List.from(data as List));
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

  Future<void> closeMyFinancialHelp(int index) async {
    try {
      isLoading = true;
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
}
