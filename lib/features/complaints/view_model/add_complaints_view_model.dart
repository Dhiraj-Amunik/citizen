import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/request/request_authorities_model.dart';
import 'package:inldsevak/features/complaints/model/response/authorites_model.dart'
    as authorities;
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart'
    as departments;
import 'package:inldsevak/features/complaints/model/response/constituency_model.dart'
    as constituency;
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:provider/provider.dart';

class AddComplaintsViewModel extends BaseViewModel
    with CupertinoDialogMixin, TransparentCircular {
  @override
  Future<void> onInit() {
    getConstituencies();
    getDepartments();
    return super.onInit();
  }

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final constituenciesController = SingleSelectController<constituency.Data>(
    null,
  );
  final descriptionController = TextEditingController();
  final departmentController = SingleSelectController<departments.Data>(null);
  final authortiyController = SingleSelectController<authorities.Data>(null);

  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  List<departments.Data> departmentLists = [];
  List<authorities.Data> authoritiesLists = [];
  List<constituency.Data> constituencyLists = [];
 update() {
    notifyListeners();
  }

  Future<void> lodgeComplaints() async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      isLoading = true;

      final FormData form = FormData.fromMap({
        "department": departmentController.value?.sId,
        "authorityId": authortiyController.value?.sId,
        "constituency": constituenciesController.value?.sId,
        "subject": titleController.text,
        "message": descriptionController.text,
      });

      final response = await ComplaintsRepository().addComplaints(
        data: form,
        token: token ?? '',
      );
      if (response.data?.success == true) {
        CommonSnackbar(text: 'Complaints has been Lodge').showToast();
        final BuildContext context =
            RouteManager.navigatorKey.currentState!.context;
        if (context.mounted) {
          await context.read<ComplaintsViewModel>().getComplaints();
        }
        RouteManager.pop();
      } else {
        CommonSnackbar(text: 'Something went wrong').showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> getDepartments() async {
    try {
      showCustomDialogTransperent(isShowing: true);
      final response = await ComplaintsRepository().getDepartments(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(text: "No departments found").showToast();
        } else {
          departmentLists = List<departments.Data>.from(data as List);
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      showCustomDialogTransperent(isShowing: false);
    }
  }

  Future<void> getConstituencies() async {
    try {
      final response = await ComplaintsRepository().getConstituencies(token);
      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(text: "No constituencies found").showToast();
        } else {
          constituencyLists = List<constituency.Data>.from(data as List);
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> getAuthorities({required String? id}) async {
    try {
      showCustomDialogTransperent(isShowing: true);

      final model = RequestAuthoritiesModel(departemnetID: id);
      final response = await ComplaintsRepository().getAuthorites(
        token: token,
        data: model,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(text: "No departments found").showToast();
        } else {
          authoritiesLists = List<authorities.Data>.from(data as List);
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      showCustomDialogTransperent(isShowing: false);
    }
  }

  //image

  File? image;

  Future<void> selectImage() async {
    customRightCupertinoDialog(
      content: "Choose Image",
      rightButton: "Sure",
      onTap: () async {
        try {
          image = await pickGalleryImage();
          notifyListeners();
        } catch (err, stackTrace) {
          debugPrint("Error: $err");
          debugPrint("Stack Trace: $stackTrace");
        }
        RouteManager.pop();
      },
    );
  }

  void removeImage() {
    image = null;
    notifyListeners();
  }
}
