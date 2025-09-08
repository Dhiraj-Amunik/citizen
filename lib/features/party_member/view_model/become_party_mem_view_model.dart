import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:inldsevak/core/extensions/list_extension.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/services/upload_image_repo.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/party_member/model/request/party_member_request_model.dart';
import 'package:inldsevak/features/party_member/model/request/request_member_details.dart';
import 'package:inldsevak/features/party_member/services/party_member_repository.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';

class BecomePartyMemViewModel extends BaseViewModel
    with CupertinoDialogMixin, TransparentCircular {
  bool visibility = true;
  bool isEnable = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final fullNameController = TextEditingController();
  final parentNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final dobController = TextEditingController();
  String? companyDateFormat;
  final genderController = SingleSelectController<String>(null);
  final maritalStatusController = SingleSelectController<String>(null);
  final constituencyController = SingleSelectController<String>(null);
  File? photographyPicture;
  final reasonController = TextEditingController();
  final roleController = SingleSelectController<String>(null);

  List<String> gendersList = ["male", "female", "others"];
  List<String> maritalStatusList = [
    "married",
    "un-married",
    "divorced",
    "widow",
    "seperated",
  ];
  List<String> constituencyList = [
    "KALKA",
    "PANCHKULA",
    "NARAINGARH",
    "AMBALA CANTT.",
    "AMBALA CITY",
    "MULANA (SC)",
    "SADHAURA(SC)",
    "JAGADHRI",
    "YAMUNANAGAR",
    "RADAUR",
    "LADWA",
    "SHAHBAD(SC)",
    "THANESAR",
    "PEHOWA",
    "GUHLA(SC)",
    "KALAYAT",
    "KAITHAL",
    "PUNDRI",
    "NILOKHERI(SC)",
    "INDRI",
    "KARNAL",
    "GHARAUNDA",
    "ASSANDH",
    "PANIPAT RURAL",
    "PANIPAT CITY",
    "ISRANA(SC)",
    "SAMALKHA",
    "GANAUR",
    "RAI",
    "KHARKHAUDA(SC)",
    "SONIPAT",
    "GOHANA",
    "BARODA",
    "MEHAM",
    "GARHI SAMPLA-KILOI",
    "ROHTAK",
    "KALANAUR(SC)",
    "BAHADURGARH",
    "BADLI",
    "JHAJJAR(SC)",
    "BERI",
    "BADHRA",
    "DADRI",
    "LOHARU",
    "BHIWANI",
    "TOSHAM",
    "BAWANI KHERA(SC)",
    "JULANA",
    "SAFIDON",
    "JIND",
    "UCHANA KALAN",
    "NARWANA(SC)",
    "TOHANA",
    "FATEHABAD",
    "RATIA(SC)",
    "KALAWALI(SC)",
    "DABWALI",
    "RANIA",
    "SIRSA",
    "ELLENABAD",
    "ADAMPUR",
    "UKLANA(SC)",
    "NARNAUND",
    "HANSI",
    "BARWALA",
    "HISAR",
    "NALWA",
    "ATELI",
    "MAHENDRAGARH",
    "NARNAUL",
    "NANGAL CHAUDHRY",
    "BAWAL(SC)",
    "KOSLI",
    "REWARI",
    "PATAUDI(SC)",
    "BADSHAHPUR",
    "GURGAON",
    "SOHNA",
    "NUH",
    "FEROZEPUR JHIRKA",
    "PUNAHANA",
    "HATHIN",
    "HODAL(SC)",
    "PALWAL",
    "PRITHLA",
    "FARIDABAD NIT",
    "BADKHAL",
    "BALLABHGARH",
    "FARIDABAD",
    "TIGAON",
  ];
  List<String> rolesList = ["MLA"];

  Future<void> selectImage() async {
    customRightCupertinoDialog(
      content: "Choose Image",
      rightButton: "Sure",
      onTap: () async {
        try {
          photographyPicture = await pickGalleryImage();
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
    photographyPicture = null;
    notifyListeners();
  }

  Future<void> submitApplication() async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      isLoading = true;
      final data = PartyMemberRequestModel(
        phone: mobileNumberController.text,
        userName: fullNameController.text,
        parentName: parentNameController.text,
        dateOfBirth: companyDateFormat,
        gender: genderController.value,
        maritalStatus: maritalStatusController.value,
        constituency: constituencyController.value,
        avatar: await uploadImage(),
        reason: reasonController.text,
        preferredRole: roleController.value,
      );

      final response = await PartyMemberRepository().createPartyMember(
        data: data,
        token: token!,
      );
      if (response.data!.responseCode == 200) {
        await CommonSnackbar(
          text: response.data?.message ?? "Request sended successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
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

        constituencyController.value = _safeFindMatch(
          constituencyList,
          user?.constituency,
        );

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

  Future<String?> uploadImage() async {
    try {
      if (photographyPicture != null) {
        final FormData data = FormData.fromMap({
          'file': await MultipartFile.fromFile(photographyPicture!.path),
        });

        final response = await UploadImageRepository().uploadPicture(
          data: data,
          token: token ?? '',
        );
        if (response.data?.responseCode == 200) {
          return response.data?.imagePath1;
        } else {
          CommonSnackbar(text: "Unable to upload image").showSnackbar();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return "";
  }

  String? _safeFindMatch(List<String> options, String? value) {
    if (value == null) return null;
    return options.firstWhereOrNull(
      (option) => option.toLowerCase() == value.toLowerCase(),
    );
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
    roleController.dispose();
    super.dispose();
  }
}
