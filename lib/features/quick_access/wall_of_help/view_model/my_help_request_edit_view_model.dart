import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_finanical_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart'
    as types;
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart'
    as preferred;
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_requests_view_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class MyHelpRequestEditViewModel extends BaseViewModel {
  MyHelpRequestEditViewModel({
    required model.FinancialRequest data,
    required List<preferred.Data> preferredData,
    required List<types.Data> typesData,
  }) {
    loadData(data: data, preferredList: preferredData, typeList: typesData);
    initialize();
  }
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
  final otherTypeController = TextEditingController();
  final otherPreferredController = TextEditingController();
  final upiIdController = TextEditingController();

  final typeOfHelpController = SingleSelectController<types.Data?>(null);
  final urgencyController = SingleSelectController<String?>(null);
  final preferredWayController = SingleSelectController<preferred.Data?>(null);

  List<preferred.Data> preferredWaysList = [];
  List<types.Data> typeOfHelpsList = [];
  List<String> urgencyList = [
    'Immediate (within 24 hours)',
    'Soon (within a week)',
    'Not Urgent (whenever possible)',
  ];
  List<String> documents = [];

  Future<void> updateFinancialHelp(String? id) async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;

      final model = RequestFinancialHelpModel(
        financialHelpRequestId: id,
        name: nameController.text,
        phone: phoneController.text,
        amountRequested: int.tryParse(amountController.text) ?? 0,
        urgency: urgencyController.value,
        description: descriptionController.text,
        documents: documents,
        typeOfHelpId: typeOfHelpController.value?.sId,
        otherTypeOfHelp: otherTypeController.text,
        preferredWayForHelpId: preferredWayController.value?.sId,
        otherPreferredWay: otherPreferredController.text,
        address: addressController.text,
        upi: upiIdController.text,
      );

      final response = await WallOfHelpRepository().updateFinancialHelp(
        token: token,
        model: model,
      );

      if (response.data?.responseCode == 200) {
        await RouteManager.context.read<MyHelpRequestsViewModel>().onRefresh();
        await CommonSnackbar(
          text: response.data?.message ?? "Updated successfully",
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

  loadData({
    required model.FinancialRequest data,
    required List<preferred.Data> preferredList,
    required List<types.Data> typeList,
  }) {
    try {
      documents.addAll(data.documents ?? []);
      preferredWaysList.addAll(preferredList);
      typeOfHelpsList.addAll(typeList);
      nameController.text = data.name ?? "";
      phoneController.text = data.phone ?? "";
      addressController.text = data.address ?? "";
      descriptionController.text = data.description ?? "";
      amountController.text = data.amountRequested.toString();
      typeOfHelpController.value = typeOfHelpsList.firstWhere(
        (type) => type.sId == data.typeOfHelp?.sId,
      );
      preferredWayController.value = preferredWaysList.firstWhere(
        (preferred) => preferred.sId == data.preferredWayForHelp?.sId,
      );
      urgencyController.value = data.urgency?.capitalize();
      upiIdController.text = data.uPI ?? "";
      otherTypeController.text = data.othersTypeOfHelp ?? "";
      otherPreferredController.text = data.othersWayForHelp ?? "";
    } catch (err) {
      CommonSnackbar(text: "Something went wrong").showToast();
    }
  }

  clear() {
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    descriptionController.clear();
    phoneController.clear();
    amountController.clear();
    urgencyController.clear();
    typeOfHelpController.clear();
    preferredWayController.clear();
  }
}
