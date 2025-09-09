import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/list_extension.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/models/response/user_profile_model.dart'
    as model;
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/request/user_register_request_model.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/profile/services/profile_repository.dart';
import 'package:intl/intl.dart';

class ProfileViewModel extends BaseViewModel with CupertinoDialogMixin {
  GlobalKey<FormState> userDetailsFormKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.onUserInteraction;

  final emailFocus = FocusNode();

  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  String? companyDateFormat;
  final aadharController = TextEditingController();

  List<String> genderList = ['Male', 'Female', 'others'];
  final genderController = SingleSelectController<String>(null);

  model.Data? profile;
  Predictions? address;

  @override
  Future<void> onInit() async {
    await getUserProfile();
  }

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

  Future<void> getUserProfile() async {
    try {
      isLoading = true;
      final response = await ProfileRepository().getUserProfile(token: token!);
      if (response.data?.responseCode == 200) {
        profile = response.data?.data;
        companyDateFormat = profile?.dateOfBirth;
        profile?.dateOfBirth = (profile?.dateOfBirth?.isNotEmpty ?? false)
            ? DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.parse(profile?.dateOfBirth ?? ""))
            : null;
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> updateUserProfile() async {
    try {
      if (!userDetailsFormKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }

      isLoading = true;

      final data = RequestRegisterModel(
        name: nameController.text,
        email: emailController.text,
        dateOfBirth: companyDateFormat,
        gender: genderController.value?.toLowerCase(),
        document: [
          Document(documentUrl: "", documentNumber: aadharController.text),
        ],
        address: "",
        avatar: "",
        location: Location(coordinates: []),
      );
      final response = await ProfileRepository().updateUserProfile(
        token: token!,
        data: data,
      );
      if (response.data?.responseCode == 200) {
        profile = response.data?.data;
        companyDateFormat = profile?.dateOfBirth;
        profile?.dateOfBirth = (profile?.dateOfBirth?.isNotEmpty ?? false)
            ? DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.parse(profile?.dateOfBirth ?? ""))
            : null;
        CommonSnackbar(text: "Profile updated successfully").showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  loadProfile() {
    nameController.text = profile?.name ?? "";
    emailController.text = profile?.email ?? "";
    phoneNumberController.text = profile?.phone ?? "";
    dobController.text = profile?.dateOfBirth ?? "";
    aadharController.text = profile?.document?.first.documentNumber ?? "";
    genderController.value = _safeFindMatch(genderList, profile?.gender);
    address = Predictions(description: profile?.address);
  }

  removeProfile() {
    nameController.text = profile?.name ?? "";
    emailController.text = profile?.email ?? "";
    phoneNumberController.text = profile?.phone ?? "";
    dobController.text = profile?.dateOfBirth ?? "";
    aadharController.text = profile?.address ?? "";
    genderController.value = _safeFindMatch(genderList, profile?.gender?.capitalize());
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    dobController.dispose();
    aadharController.dispose();
    genderController.dispose();
    emailFocus.dispose();
    super.dispose();
  }
}

String? _safeFindMatch(List<String> options, String? value) {
  if (value == null) return null;
  return options.firstWhereOrNull(
    (option) => option.toLowerCase() == value.toLowerCase(),
  );
}
