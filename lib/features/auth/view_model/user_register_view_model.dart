import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/features/auth/models/request/user_register_request_model.dart';
import 'package:inldsevak/features/auth/services/user_profile_repository.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/restart_app.dart';

class UserRegisterViewModel extends BaseViewModel with CupertinoDialogMixin {
  GlobalKey<FormState> userDetailsFormKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final nameFocus = FocusNode();
  final fatherNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final wathsappFocus = FocusNode();

  final nameController = TextEditingController();
  final whathsappNoController = TextEditingController();
  final fatherNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  String? companyDateFormat;
  final aadharController = TextEditingController();
  final voterIdController = TextEditingController();

  List<String> genderList = ['Male', 'Female', 'others'];
  final genderController = SingleSelectController<String>(null);

  File? aadharImage;
  File? voterIdImage;

  Future<void> selectImage({required bool isAadhar}) async {
    customRightCupertinoDialog(
      content: "Choose Image",
      rightButton: "Sure",
      onTap: () async {
        try {
          if (isAadhar) {
            aadharImage = await pickGalleryImage();
          } else {
            voterIdImage = await pickGalleryImage();
          }
          notifyListeners();
        } catch (err, stackTrace) {
          debugPrint("Error: $err");
          debugPrint("Stack Trace: $stackTrace");
        }
        RouteManager.pop();
      },
    );
  }

  void removeImage({required bool isAadhar}) {
    if (isAadhar) {
      aadharImage = null;
    } else {
      voterIdImage = null;
    }
    notifyListeners();
  }

  Future<void> registerUserDetails({
    AddressModel? addressModel,
    String? constituenciesID,
  }) async {
    try {
      if (userDetailsFormKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      if (addressModel == null) {
        CommonSnackbar(text: "Please select your address again").showToast();
        return;
      }
      isLoading = true;

      final data = RequestRegisterModel(
        name: nameController.text,
        email: emailController.text,
        dateOfBirth: companyDateFormat!,
        gender: genderController.value!.toLowerCase(),
        constituencyId: constituenciesID,
        document: [
          Document(
            documentType: "aadhaar",
            documentUrl: "",
            documentNumber: aadharController.text.replaceAll(" ", ''),
          ),
          Document(
            documentType: "voterId",
            documentUrl: "",
            documentNumber: voterIdController.text,
          ),
        ],
        address: addressModel.formattedAddress,
        city: addressModel.city,
        state: addressModel.state,
        district: addressModel.district,
        pincode: addressModel.pincode,
        avatar: "",
        location: Location(
          coordinates: [addressModel.latitude, addressModel.longitude],
        ),
        whatsappNo: whathsappNoController.text,
      );
      final response = await UserProfileRepository().userRegister(
        data: data,
        token: token!,
      );
      if (response.data?.responseCode == 200) {
        if (response.data?.data?.isRegistered == true) {
          RestartApp.restartApp();
          CommonSnackbar(
            text: response.data?.message ?? 'User registered successfully.',
          ).showToast();
          // await uploadProfilePic();
        } else {
          CommonSnackbar(
            text: response.data?.message ?? 'Something went wrong',
          ).showSnackbar();
        }

        if (RouteManager.navigatorKey.currentState!.canPop()) {
          RouteManager.popUntilHome();
        }
      } else {
        CommonSnackbar(
          text:
              response.data?.message ??
              'Something went wrong'
                  "Unable to upload image, Please try again later",
        ).showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  // Future<void> uploadProfilePic() async {
  //   try {
  //     if (profilePicture != null) {
  //       final FormData data = FormData.fromMap({
  //         'file': await MultipartFile.fromFile(profilePicture!.path),
  //       });

  //       // final response = await UserProfileRepository().uploadUserPicture(
  //       //   data: data,
  //       //   token: token ?? '',
  //       // );
  //       // if (response.data?.responseCode == 200) {
  //       //   CommonSnackbar(
  //       //     text: "Profile Pic updated successfully",
  //       //   ).showSnackbar();
  //       // } else {
  //       //   CommonSnackbar(text: "Something went wrong.").showSnackbar();
  //       // }
  //     } else {
  //       CommonSnackbar(
  //         text: "Please select one image to upload.",
  //       ).showSnackbar();
  //     }
  //   } catch (err, stackTrace) {
  //     debugPrint("Error: $err");
  //     debugPrint("Stack Trace: $stackTrace");
  //   }
  // }

  void generateAadhar(String? value) {
    // Remove all spaces first
    String digitsOnly = value!.replaceAll(RegExp(r'\s+'), '');

    // Add spaces after every 4 characters
    String formattedValue = digitsOnly
        .replaceAllMapped(RegExp(r".{1,4}"), (match) => "${match.group(0)} ")
        .trim();
    aadharController.value = TextEditingValue(text: formattedValue);
  }

  void generateVoter(String? value) {
    voterIdController.value = TextEditingValue(text: value!.toUpperCase());
  }

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    aadharController.dispose();
    genderController.dispose();
    super.dispose();
  }
}
