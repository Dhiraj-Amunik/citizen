import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_finanical_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class WallOfHelpViewModel extends BaseViewModel {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final nameFocus = FocusNode();
  final titleFocus = FocusNode();
  final amountFocus = FocusNode();
  final descriptionFocus = FocusNode();

  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  final searchController = TextEditingController();

  @override
  Future<void> onInit() {
    getWallOfHelpList();
    return super.onInit();
  }

  List<model.Data> wallOFHelpLists = [];
  List<model.Data> filteredWallOFHelpLists = [];

  Future<void> getWallOfHelpList() async {
    try {
      isLoading = true;
      wallOFHelpLists.clear();
      filteredWallOFHelpLists.clear();
      final response = await WallOfHelpRepository().getWallOFHelp(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isNotEmpty == true) {
          wallOFHelpLists = List<model.Data>.from(data as List);
          filteredWallOFHelpLists.addAll(wallOFHelpLists);
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> createFinancialHelp() async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;

      final model = RequestFinancialHelpModel(
        subject: titleController.text,
        reason: descriptionController.text,
        amountRequested: amountController.text,
        additionalDetails: nameController.text,
      );

      final response = await WallOfHelpRepository().createFinancialHelp(
        token: token,
        model: model,
      );

      if (response.data?.responseCode == 200) {
        await CommonSnackbar(
          text: response.data?.message ?? "Request sended successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
      RouteManager.pop();
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  filterList() {
    filteredWallOFHelpLists.clear();
    filteredWallOFHelpLists.addAll(
      wallOFHelpLists.where((help) {
        return _matchesSearch(help);
      }),
    );
    notifyListeners();
  }

  bool _matchesSearch(model.Data help) {
    final searchQuery = searchController.text.trim().toLowerCase();
    return help.title?.toLowerCase().contains(searchQuery) == true ||
        help.description?.toLowerCase().contains(searchQuery) == true;
  }
}
