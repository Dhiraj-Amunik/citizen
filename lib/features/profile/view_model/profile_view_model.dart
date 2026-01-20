import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/list_extension.dart';
import 'package:inldsevak/core/mixin/single_image_picker_mixin.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as model;
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/request/user_register_request_model.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/profile/services/profile_repository.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:inldsevak/features/profile/view_model/avatar_view_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:inldsevak/l10n/general_stream.dart';

class ProfileViewModel extends BaseViewModel
    with UploadFilesMixin, SingleImagePickerMixin {
  GlobalKey<FormState> userDetailsFormKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final emailFocus = FocusNode();

  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  String? companyDateFormat;
  final aadharController = TextEditingController();
  final voterIdController = TextEditingController();
  Constituency? parlimentaryConstituencyData;
  Constituency? assemblyConstituencyData;

  // Original English list (for API submission)
  final List<String> _genderList = ['Male', 'Female', 'others'];
  
  // Translated list (for UI display)
  List<String> get genderList {
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return _genderList;
    
    // Return translated versions
    return _genderList.map((gender) {
      switch (gender.toLowerCase()) {
        case 'male':
          return 'पुरुष';
        case 'female':
          return 'महिला';
        case 'others':
          return 'अन्य';
        default:
          return gender;
      }
    }).toList();
  }
  
  String? gender;
  
  // Helper method to get original English value from translated value for API
  String? _getOriginalGenderValue(String? translatedValue) {
    if (translatedValue == null) return null;
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return translatedValue;
    
    // Map Hindi back to English
    switch (translatedValue) {
      case 'पुरुष':
        return 'Male';
      case 'महिला':
        return 'Female';
      case 'अन्य':
        return 'others';
      default:
        return translatedValue;
    }
  }
  
  // Helper method to convert English gender to translated value for display
  String? _getTranslatedGenderValue(String? englishValue) {
    if (englishValue == null) return null;
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return englishValue;
    
    // Map English to Hindi
    switch (englishValue.toLowerCase()) {
      case 'male':
        return 'पुरुष';
      case 'female':
        return 'महिला';
      case 'others':
        return 'अन्य';
      default:
        return englishValue;
    }
  }

  model.Data? profile;
  AddressModel? address;

  @override
  Future<void> onInit() async {
    await getUserProfile();
    if (RouteManager.context.mounted) {
      await RouteManager.context
          .read<ConstituencyViewModel>()
          .getAssemblyConstituencies(
            id: parlimentaryConstituencyData?.sId,
            oldToken: token,
          );
    }
  }

  File? aadharImage;
  String? aadharURL;
  File? voterIdImage;
  String? voterIdURL;

  Future<void> selectImage({required bool isAadhar}) async {
    try {
      if (isAadhar) {
        aadharImage = await showSingleImageSheet(isImage: true);
      } else {
        voterIdImage = await showSingleImageSheet(isImage: true);
      }
      notifyListeners();
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  void removeImage({required bool isAadhar}) {
    if (isAadhar) {
      aadharImage = null;
      aadharURL = null;
    } else {
      voterIdImage = null;
      voterIdURL = null;
    }
    notifyListeners();
  }

  Future<void> getUserProfile() async {
    try {
      isLoading = true;
      final response = await ProfileRepository().getUserProfile(
        token: token ?? "",
      );
      if (response.data?.responseCode == 200) {
        profile = response.data?.data;
        companyDateFormat = profile?.dateOfBirth;
        if (profile?.parliamentryConstituency != null) {
          parlimentaryConstituencyData = profile?.parliamentryConstituency;
        }
        if (profile?.assemblyConstituency != null) {
          assemblyConstituencyData = profile?.assemblyConstituency;
        }
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> updateUserProfile({
    required MapSearchViewModel mapModel,
    String? genderValue,
    String? assemblyConstituenciesID,
    String? parliamentaryConstituenciesID,
    required AvatarViewModel avatar,
  }) async {
    try {
      // Set autoValidateMode to onUserInteraction before validation so validators run
      if (autoValidateMode == AutovalidateMode.disabled) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners(); // Notify to rebuild Consumer widgets so validator runs
      }
      
      if (!userDetailsFormKey.currentState!.validate()) {
        return;
      }

      isLoading = true;
      bool needUpdate = false;

      final data = RequestRegisterModel();

      if (avatar.userAvatar != null) {
        needUpdate = true;
        data.avatar = await uploadImage(
          avatar.userAvatar!.path,
          filename: avatar.userAvatar?.path,
          token: token ?? "",
          name: "Avatar",
        );
      }
      if (nameController.text != profile?.name) {
        data.name = nameController.text;
        needUpdate = true;
      }

      if (emailController.text != profile?.email) {
        needUpdate = true;
        data.email = emailController.text;
      }
      if (companyDateFormat != profile?.dateOfBirth) {
        needUpdate = true;
        data.dateOfBirth = companyDateFormat;
      }

      // Convert translated gender value back to English for API
      final originalGenderValue = _getOriginalGenderValue(genderValue);
      if (originalGenderValue?.toLowerCase() != profile?.gender?.toLowerCase()) {
        needUpdate = true;
        data.gender = originalGenderValue?.toLowerCase();
      }

      if (assemblyConstituenciesID != profile?.assemblyConstituency?.sId ||
          parliamentaryConstituenciesID !=
              profile?.parliamentryConstituency?.sId) {
        needUpdate = true;
        data.parliamentaryId = parliamentaryConstituenciesID;

        data.assemblyId = assemblyConstituenciesID;
      }

      if (aadharController.text.replaceAll(" ", '') !=
              getInitialDocumentNumber('aadhaar') ||
          aadharImage != null ||
          voterIdController.text != getInitialDocumentNumber('voterid') ||
          voterIdImage != null) {
        needUpdate = true;
        data.document = [
          Document(
            documentType: 'aadhaar',
            documentNumber: aadharController.text.replaceAll(" ", ''),
            documentUrl: aadharImage == null
                ? aadharURL ?? ""
                : aadharURL = await uploadImage(
                    filename: aadharImage?.path,
                    aadharImage!.path,
                    token: token ?? "",
                    name: "Aadhar",
                  ),
          ),
          Document(
            documentType: 'voterId',
            documentNumber: voterIdController.text,
            documentUrl: voterIdImage == null
                ? voterIdURL ?? ""
                : voterIdURL = await uploadImage(
                    voterIdImage!.path,
                    token: token ?? "",
                    name: "Voter ID",
                  ),
          ),
        ];
      }

      if (mapModel.cityController.text != profile?.city) {
        needUpdate = true;

        data.city = mapModel.cityController.text;
      }
      if (mapModel.districtController.text != profile?.district) {
        needUpdate = true;

        data.district = mapModel.districtController.text;
      }
      if (mapModel.stateController.text != profile?.state) {
        needUpdate = true;

        data.state = mapModel.stateController.text;
      }
      if (mapModel.pincodeController.text != profile?.pincode) {
        needUpdate = true;

        data.pincode = mapModel.pincodeController.text;
      }

      if (mapModel.tehsilController.text != profile?.teshil) {
        needUpdate = true;

        data.tehsil = mapModel.tehsilController.text;
      }

      if (mapModel.flatNoController.text != profile?.flatNumber) {
        needUpdate = true;

        data.flatNo = mapModel.flatNoController.text;
      }

      if (mapModel.areaController.text != profile?.area) {
        needUpdate = true;

        data.area = mapModel.areaController.text;
      }

      if (mapModel.currentPosition != null) {
        needUpdate = true;

        data.location = Location(
          coordinates: [
            mapModel.currentPosition?.latitude,
            mapModel.currentPosition?.longitude,
          ],
        );
      }

      if (needUpdate == false) {
        CommonSnackbar(text: "Please edit profile to update").showToast();
        return;
      }

      log(data.toJson().toString());
      final response = await ProfileRepository().updateUserProfile(
        token: token!,
        data: data,
      );
      if (response.data?.responseCode == 200) {
        mapModel.address = null;
        mapModel.currentPosition = null;
        avatar.userAvatar = null;
        aadharImage = null;
        voterIdImage = null;
        await getUserProfile();
        CommonSnackbar(
          text: "Profile updated successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  loadProfile(MapSearchViewModel mapProvider) async {
    try {
      voterIdImage = null;
      aadharImage = null;
      nameController.text = profile?.name ?? "";
      // Get the English gender value from profile and convert to translated value for display
      final englishGender = profile?.gender?.capitalize();
      final translatedGender = _getTranslatedGenderValue(englishGender);
      gender = _safeFindMatch(genderList, translatedGender) ?? translatedGender;
      emailController.text = profile?.email ?? "";
      phoneNumberController.text = profile?.phone ?? "";
      companyDateFormat = profile?.dateOfBirth ?? "";
      dobController.text = companyDateFormat?.toDdMmYyyy() ?? "";

      if (profile?.document != null && profile?.document?.isNotEmpty == true) {
        profile?.document?.forEach((document) {
          if (document.documentType?.toLowerCase() == "aadhaar") {
            final aadhaar = document.documentNumber ?? "";
            aadharController.value = TextEditingValue(
              text: aadhaar,
              selection: TextSelection.collapsed(offset: aadhaar.length),
            );
            generateAadhar(aadhaar);
            aadharURL = document.documentUrl;
          }
          if (document.documentType?.toLowerCase() == "voterid") {
            final voter = document.documentNumber ?? "";
            voterIdController.value = TextEditingValue(
              text: voter,
              selection: TextSelection.collapsed(offset: voter.length),
            );
            voterIdURL = document.documentUrl;
          }
        });
      }

      mapProvider.pincodeController.text = profile?.pincode ?? "";
      mapProvider.stateController.text = profile?.state ?? "";
      mapProvider.districtController.text = profile?.district ?? "";
      mapProvider.cityController.text = profile?.city ?? "";
      mapProvider.tehsilController.text = profile?.teshil ?? "";
      mapProvider.flatNoController.text = profile?.flatNumber ?? "";
      mapProvider.areaController.text = profile?.area ?? "";
      mapProvider.currentPosition = null;
      mapProvider.address = null;
    } catch (err) {
      CommonSnackbar(text: "Unable to load Profile").showToast();
    } finally {
      await Future.delayed(Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    dobController.dispose();
    aadharController.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  void clearProfile() {
    nameController.clear();
    emailController.clear();
    phoneNumberController.clear();
    dobController.clear();
    aadharController.clear();
    super.dispose();
  }

  void generateVoter(String? value) {
    final upper = (value ?? '').toUpperCase();
    voterIdController.value = TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }

  void generateAadhar(String? value) {
    // Remove all spaces first
    final input = value ?? '';
    String digitsOnly = input.replaceAll(RegExp(r'\s+'), '');

    // Add spaces after every 4 characters
    String formattedValue = digitsOnly
        .replaceAllMapped(RegExp(r".{1,4}"), (match) => "${match.group(0)} ")
        .trim();
    aadharController.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  String? getInitialDocumentNumber(String? docType) {
    try {
      if (profile?.document?.isEmpty == true) {
        return null;
      }
      final data = profile?.document?.firstWhere(
        (doc) => doc.documentType?.toLowerCase() == docType,
      );

      if (data == null) {
        return null;
      } else {
        return data.documentNumber;
      }
    } catch (err) {
      log("-------------------> $err $docType");
      return null;
    }
  }

  String? _safeFindMatch(List<String> options, String? value) {
    if (value == null) return null;
    return options.firstWhereOrNull(
      (option) => option.toLowerCase() == value.toLowerCase(),
    );
  }
}
