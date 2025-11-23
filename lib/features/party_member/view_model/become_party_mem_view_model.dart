import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/party_member/model/request/party_member_request_model.dart';
import 'package:inldsevak/features/party_member/services/party_member_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as profile;

class BecomePartyMemViewModel extends BaseViewModel
    with  TransparentCircular, UploadFilesMixin {
  bool visibility = true;
  bool isEnable = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final fullNameController = TextEditingController();
  final fullNameFocus = FocusNode();
  final parentNameController = TextEditingController();
  final parentNameFocus = FocusNode();
  final mobileNumberController = TextEditingController();
  final mobileFocus = FocusNode();
  final dobController = TextEditingController();
  String? companyDateFormat;
  final genderController = SingleSelectController<String>(null);
  final maritalStatusController = SingleSelectController<String>(null);
  final constituencyController = SingleSelectController<Constituency>(null);
  // File? photographyPicture;
  final reasonController = TextEditingController();

  List<String> gendersList = ["Male", "Female", "Others"];
  List<String> maritalStatusList = [
    "Married",
    "Un-married",
    "Divorced",
    "Widow",
    "Seperated",
  ];

  List<File> multipleFiles = [];

  Widget selectMultipleImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.camera),
          title: TranslatedText(text: 'Take a Picture'),
          onTap: () async {
            RouteManager.pop();
            await Future.delayed(const Duration(milliseconds: 300));
            try {
              final file = await createCameraImage();
              if (file != null && await file.exists()) {
                final fileSize = await file.length();
                if (fileSize > 0) {
                  multipleFiles.add(file);
                  notifyListeners();
                } else {
                  CommonSnackbar(
                    text: "Image file is invalid. Please try again.",
                  ).showAnimatedDialog(type: QuickAlertType.error);
                }
              }
            } catch (err, stackTrace) {
              debugPrint("Error capturing image: $err");
              debugPrint("Stack trace: $stackTrace");
              CommonSnackbar(
                text: "Failed to capture image. Please try again.",
              ).showAnimatedDialog(type: QuickAlertType.error);
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: TranslatedText(text: 'Choose from Gallery'),
          onTap: () async {
            RouteManager.pop();
            try {
              multipleFiles.addAll(await pickMultipleImages() ?? []);
              notifyListeners();
            } catch (err) {
              debugPrint("-------->$err");
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.file_open),
          title: TranslatedText(text: 'Choose from Files'),
          onTap: () async {
            RouteManager.pop();
            try {
              multipleFiles.addAll(await pickFiles() ?? []);
              notifyListeners();
            } catch (err) {
              debugPrint("-------->$err");
            }
          },
        ),
      ],
    );
  }

  void removeImage(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  Future<void> submitApplication({String? parlimentConstituencyID}) async {
    try {
      if (parlimentConstituencyID == null) {
        return CommonSnackbar(
          text: "Please add Parliment in My Profile",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      isLoading = true;
      final data = PartyMemberRequestModel(
        documents: [],
        phone: mobileNumberController.text,
        assemblyConstituenciesID: constituencyController.value!.sId!,
        parliamentaryConstituencyId: parlimentConstituencyID,
        userName: fullNameController.text,
        parentName: parentNameController.text,
        dateOfBirth: companyDateFormat,
        gender: genderController.value,
        maritalStatus: maritalStatusController.value,
        reason: "Request to Join Party",
        images: multipleFiles.isEmpty
            ? []
            : await uploadMultipleImage(multipleFiles),
      );

      final response = await PartyMemberRepository().createPartyMember(
        data: data,
        token: token!,
      );
      if (response.data!.responseCode == 200) {
        await CommonSnackbar(
          text: response.data?.message ?? "Request sended successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
        RouteManager.pop();
        isEnable = false;
      } else {
        CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      CommonSnackbar(
        text: "Something went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  autoFillData(profile.Data? profile) {
    fullNameController.text = profile?.name ?? "";
    mobileNumberController.text = profile?.phone ?? "";
    dobController.text = profile?.dateOfBirth?.toDdMmYyyy() ?? "";
    companyDateFormat = profile?.dateOfBirth ?? "";
    genderController.value = profile?.gender?.capitalize();
  }

  void clear() {
    fullNameController.clear();
    parentNameController.clear();
    mobileNumberController.clear();
    dobController.clear();
    companyDateFormat = null;
    genderController.clear();
    maritalStatusController.clear();
    // reasonController.clear();
    multipleFiles.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    parentNameController.dispose();
    mobileNumberController.dispose();
    dobController.dispose();
    genderController.dispose();
    maritalStatusController.dispose();
    constituencyController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}


/*


  Future<void> getUserDetails() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      showCustomDialogTransperent(isShowing: true);
      final data = RequestMemberDetails(
        phoneNumber: mobileNumberController.text,
      );
      final response = await PartyMemberRepository().getUserDetails(
        data: data,
        token: token!,
      );

      if (response.data?.responseCode == 200) {
        final user = response.data?.data?.user;
        final formattedDate = (user?.dateOfBirth?.isNotEmpty ?? false)
            ? DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.parse(user?.dateOfBirth ?? ""))
            : null;
        fullNameController.text = user?.name ?? "";
        parentNameController.text = user?.parentName ?? "";
        dobController.text = formattedDate ?? "";
        companyDateFormat = user?.dateOfBirth ?? "";
        genderController.value = _safeFindMatch(gendersList, user?.gender);

        maritalStatusController.value = _safeFindMatch(
          maritalStatusList,
          user?.maritalStatus,
        );

        // constituencyController.value = _safeFindMatch(
        //   constituencyList,
        //   user?.constituency,
        // );

        roleController.value = _safeFindMatch(rolesList, user?.preferredRole);
        if (response.data?.data?.partyMemberDetails?.status == "approved") {
          await CommonSnackbar(
            text: "You have become one of our Party member",
          ).showAnimatedDialog(type: QuickAlertType.success);
        } else if (response.data?.data?.partyMemberDetails?.status ==
            "pending") {
          await CommonSnackbar(
            text: "Request is Pending! Please wait to get approved",
          ).showAnimatedDialog(type: QuickAlertType.info);
        } else {
          isEnable = true;
        }
        notifyListeners();
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Mobile Number not registered",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
      visibility = true;
    } catch (err, stackTrace) {
      await CommonSnackbar(
        text: "Something went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      showCustomDialogTransperent(isShowing: false);
    }
  }

 


*/