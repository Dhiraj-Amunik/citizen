import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_finanical_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/woh_pagination_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart'
    as types;
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart'
    as preferred;

class WallOfHelpViewModel extends BaseViewModel with UploadFilesMixin {
  final WallOfHelpRepository repository = WallOfHelpRepository();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final addressFocus = FocusNode();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final upiIdController = TextEditingController();
  final otherTypeController = TextEditingController();
  final otherPreferredController = TextEditingController();

  final searchController = TextEditingController();
  Timer? _debounce;

  String? statusKey;
  String? dateKey;
  List<String> statusItems = [
    "all",
    "approved",
    "Partially-Funded",
    "Fully-Funded",
  ];
  List<String> dateItems = ["Recent", "One Month", "Six Months"];

  setStatus(String status) {
    statusKey = status;
    notifyListeners();
  }

  setDate(String status) {
    dateKey = status;
    notifyListeners();
  }

  @override
  Future<void> onInit() {
    Future.wait([getWallOfHelpList(), getTypes(), getPreferred()]);
    scrollController.addListener(_scrollListener);
    return super.onInit();
  }

  List<model.FinancialRequest> wallOFHelpLists = [];
  List<preferred.Data> preferredWaysList = [];
  List<types.Data> typeOfHelpsList = [];
  List<String> urgencyList = [
    'Immediate (within 24 hours)',
    'Soon (within a week)',
    'Not Urgent (whenever possible)',
  ];

  //documents
  List<File> multipleFiles = [];

  Future<void> addFiles(Future<dynamic> future) async {
    RouteManager.pop();
    try {
      final data = await future;
      if (data != null) {
        List<File> tempFiles = [...multipleFiles];
        tempFiles.addAll(data);
        if (tempFiles.length >= 6) {
          return CommonSnackbar(
            text: "Max 5 Files are accepted",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
          multipleFiles.addAll(await future);
          notifyListeners();
        }
      }
    } catch (err) {
      debugPrint("-------->$err");
    }
  }

  void removefile(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  onSearchChanged(String? query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (statusKey != null || dateKey != null) {
        statusKey = null;
        dateKey = null;
      }
      onRefresh();
    });
  }

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
      getWallOfHelpList();
    }
  }

  onRefresh() {
    _currentPage = 1;
    _isLastPage = false;
    getWallOfHelpList();
  }

  int _currentPage = 1;
  bool _isLastPage = false;

  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  set isScrollLoading(bool value) {
    _isScrollLoading = value;
    notifyListeners();
  }

  Future<void> getWallOfHelpList() async {
    if (_currentPage == 1) {
      isLoading = true;
      wallOFHelpLists.clear();
    } else {
      isScrollLoading = true;
    }
    try {
      final paginationModel = WOHPaginationModel(
        page: _currentPage,
        search: searchController.text.isEmpty ? null : searchController.text,
        status: statusKey == "all" || statusKey == null ? null : statusKey,
        date: dateKey == "Recent"
            ? 7
            : dateKey == "One Month"
            ? 30
            : dateKey == "Six Months"
            ? 180
            : null,
      );
      final response = await WallOfHelpRepository().getUsersWallOFHelp(
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
          wallOFHelpLists.addAll(List.from(data as List));
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

  Future<void> createFinancialHelp({
    String? urgency,
    String? typeOFHelp,
    String? preferredWay,
  }) async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;

      final model = RequestFinancialHelpModel(
        name: nameController.text,
        phone: phoneController.text,
        amountRequested: int.tryParse(amountController.text) ?? 0,
        urgency: urgency,
        description: descriptionController.text,
        documents: multipleFiles.isEmpty
            ? []
            : await uploadMultipleImage(multipleFiles),
        typeOfHelpId: typeOFHelp,
        otherTypeOfHelp: otherTypeController.text,
        preferredWayForHelpId: preferredWay,
        otherPreferredWay: otherPreferredController.text,
        address: addressController.text,
        upi: upiIdController.text,
      );

      final response = await WallOfHelpRepository().createFinancialHelp(
        token: token,
        model: model,
      );

      if (response.data?.responseCode == 200) {
        await CommonSnackbar(
          text: response.data?.message ?? "Request sended successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
        RouteManager.pop();
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> getTypes() async {
    try {
      final response = await repository.getHelpsDD(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        typeOfHelpsList = List<types.Data>.from(data as List);
      } else {
        CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> getPreferred() async {
    try {
      final response = await repository.getPreferredWaysDD(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        preferredWaysList = List<preferred.Data>.from(data as List);
      } else {
        CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  clear() {
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    descriptionController.clear();
    searchController.clear();
    phoneController.clear();
    amountController.clear();
    multipleFiles.clear();

    notifyListeners();
  }
}
