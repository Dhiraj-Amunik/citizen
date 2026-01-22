import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
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

class MyHelpRequestEditViewModel extends BaseViewModel with UploadFilesMixin {
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
  List<File> multipleFiles = [];
  final List<String> _existingDocuments = [];
  List<String> get existingDocuments => List.unmodifiable(_existingDocuments);

  Future<void> updateFinancialHelp(String? id) async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;
      notifyListeners();

      // Upload new files if any
      List<String> uploadedDocuments = [];
      if (multipleFiles.isNotEmpty) {
        uploadedDocuments = await uploadMultipleImage(multipleFiles);
        if (uploadedDocuments.isEmpty) {
          isLoading = false;
          notifyListeners();
          await CommonSnackbar(
            text: "Failed to upload images. Please try again.",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          return;
        }
      }
      
      // Combine existing documents (that weren't removed) and newly uploaded documents
      final allDocuments = [
        ..._existingDocuments,
        ...uploadedDocuments,
      ];

      final model = RequestFinancialHelpModel(
        financialHelpRequestId: id,
        name: nameController.text,
        phone: phoneController.text,
        amountRequested: int.tryParse(amountController.text) ?? 0,
        urgency: urgencyController.value,
        description: descriptionController.text,
        documents: allDocuments,
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
        // Show success popup first
        await CommonSnackbar(
          text: response.data?.message ?? "Updated successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
        
        // Try to refresh the list - attempt to get from RouteManager context
        try {
          final context = RouteManager.context;
          if (context.mounted) {
            final myRequestsViewModel = context.read<MyHelpRequestsViewModel>();
            // Await the refresh to ensure data is updated before navigating back
            await myRequestsViewModel.onRefresh();
          }
        } catch (e) {
          debugPrint("Could not refresh MyHelpRequestsViewModel: $e");
        }
        
        // Pop with success result to indicate update was successful
        RouteManager.pop(true);
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
      // Clear and populate existing documents
      _existingDocuments.clear();
      _existingDocuments.addAll(data.documents ?? []);
      // Keep documents list in sync for backward compatibility
      documents.clear();
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

  Future<void> addFiles(Future<dynamic> future) async {
    // Note: Bottom sheet is already closed in handle_multiple_files_sheet.dart
    // No need to pop here as it would close the form page
    try {
      // Add delay to let system stabilize after image capture (critical for older devices)
      await Future.delayed(const Duration(milliseconds: 200));
      
      final data = await future;
      if (data != null && data is List) {
        // Validate files before adding
        final validFiles = <File>[];
        for (final item in data) {
          if (item is File) {
            try {
              if (await item.exists()) {
                final fileSize = await item.length();
                if (fileSize > 0 && fileSize < 5 * 1024 * 1024) {
                  validFiles.add(item);
                }
              }
            } catch (e) {
              debugPrint("Error validating file in addFiles: $e");
              // Continue with other files
            }
          }
        }
        
        if (validFiles.isEmpty) {
          CommonSnackbar(
            text: "No valid files to add. Please try again.",
          ).showAnimatedDialog(type: QuickAlertType.error);
          return;
        }
        
        List<File> tempFiles = [...multipleFiles];
        tempFiles.addAll(validFiles);
        if (tempFiles.length >= 6) {
          CommonSnackbar(
            text: "Max 5 Files are accepted",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          return;
        }
        
        multipleFiles.addAll(validFiles);
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error in addFiles: $err");
      debugPrint("Stack trace: $stackTrace");
      CommonSnackbar(
        text: "Failed to add files. Please try again.",
      ).showAnimatedDialog(type: QuickAlertType.error);
    }
  }

  void removeImage(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  void removeExistingDocument(int index) {
    if (index < 0 || index >= _existingDocuments.length) return;
    _existingDocuments.removeAt(index);
    // Also remove from documents list to keep them in sync
    if (index < documents.length) {
      documents.removeAt(index);
    }
    notifyListeners();
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
