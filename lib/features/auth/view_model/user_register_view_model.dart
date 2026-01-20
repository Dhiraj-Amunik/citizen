import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/mixin/single_image_picker_mixin.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/request/user_register_request_model.dart';
import 'package:inldsevak/features/auth/services/user_profile_repository.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';

class UserRegisterViewModel extends BaseViewModel
    with CupertinoDialogMixin, UploadFilesMixin, SingleImagePickerMixin {
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
  final invitedByController = TextEditingController();

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
  
  final genderController = SingleSelectController<String>(null);
  
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

  File? aadharImage;
  File? voterIdImage;

  Future<void> selectImage({required bool isAadhar}) async {
    try {
      debugPrint("🔵 [selectImage] Called - isAadhar: $isAadhar");
      debugPrint("🔵 [selectImage] Before showSingleImageSheet - aadharImage: ${aadharImage?.path}, voterIdImage: ${voterIdImage?.path}");
      
      final File? selectedImage = await showSingleImageSheet(isImage: true);
      
      debugPrint("🔵 [selectImage] After showSingleImageSheet - selectedImage: ${selectedImage?.path}");
      debugPrint("🔵 [selectImage] selectedImage is null: ${selectedImage == null}");
      
      if (selectedImage != null) {
        debugPrint("🔵 [selectImage] Selected image path: ${selectedImage.path}");
        
        // Verify file exists before setting
        final fileExists = await selectedImage.exists().catchError((error) {
          debugPrint("🔴 [selectImage] Error checking file existence: $error");
          return false;
        });
        
        debugPrint("🔵 [selectImage] File exists: $fileExists");
        
        if (fileExists) {
      if (isAadhar) {
            debugPrint("🔵 [selectImage] Setting aadharImage to: ${selectedImage.path}");
            aadharImage = selectedImage;
            debugPrint("🔵 [selectImage] aadharImage set successfully: ${aadharImage?.path}");
      } else {
            debugPrint("🔵 [selectImage] Setting voterIdImage to: ${selectedImage.path}");
            voterIdImage = selectedImage;
            debugPrint("🔵 [selectImage] voterIdImage set successfully: ${voterIdImage?.path}");
      }
          
          // Ensure listeners are notified after image is set
          debugPrint("🔵 [selectImage] Calling notifyListeners()");
      notifyListeners();
          debugPrint("🔵 [selectImage] notifyListeners() called - aadharImage: ${aadharImage?.path}, voterIdImage: ${voterIdImage?.path}");
        } else {
          debugPrint("🔴 [selectImage] File does not exist at path: ${selectedImage.path}");
        }
      } else {
        debugPrint("🔴 [selectImage] selectedImage is null, not setting image");
      }
    } catch (err, stackTrace) {
      debugPrint("🔴 [selectImage] Error: $err");
      debugPrint("🔴 [selectImage] Stack Trace: $stackTrace");
    }
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
    MapSearchViewModel? searchProvider,
    String? assemblyConstituenciesID,
    String? parliamentaryConstituenciesID,
  }) async {
    try {
      if (userDetailsFormKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }

      isLoading = true;

      // Build document list conditionally
      final List<Document> documents = [
        Document(
          documentType: "aadhaar",
          documentUrl: aadharImage == null
              ? ""
              : await uploadImage(
                  filename: aadharImage?.path,
                  aadharImage!.path,
                  token: token ?? "",
                  name: "Aadhar",
                ),
          documentNumber: aadharController.text.replaceAll(" ", ''),
        ),
      ];

      // Only add voter ID document if voter ID is provided and not empty
      final voterIdText = voterIdController.text.trim();
      if (voterIdText.isNotEmpty) {
        documents.add(
          Document(
            documentType: "voterId",
            documentUrl: voterIdImage == null
                ? ""
                : await uploadImage(
                    voterIdImage!.path,
                    token: token ?? "",
                    name: "Voter ID",
                  ),
            documentNumber: voterIdText,
          ),
        );
      }

      final data = RequestRegisterModel(
        name: nameController.text,
        fatherName: "",
        email: emailController.text,
        dateOfBirth: companyDateFormat!,
        gender: _getOriginalGenderValue(genderController.value)?.toLowerCase() ?? genderController.value!.toLowerCase(),
        parliamentaryId: parliamentaryConstituenciesID,
        assemblyId: assemblyConstituenciesID,
        document: documents,
        city: searchProvider?.cityController.text,
        state: searchProvider?.stateController.text,
        district: searchProvider?.districtController.text,
        pincode: searchProvider?.pincodeController.text,
        area: searchProvider?.areaController.text,
        flatNo: searchProvider?.flatNoController.text,
        tehsil: searchProvider?.tehsilController.text,
        avatar: "",
        location: Location(
          coordinates: [
            searchProvider?.currentPosition?.latitude ?? 0.0,
            searchProvider?.currentPosition?.longitude ?? 0.0,
          ],
        ),
        whatsappNo: whathsappNoController.text,
        invitedBy: invitedByController.text.trim().isEmpty 
            ? null 
            : invitedByController.text.trim(),
      );

      final response = await UserProfileRepository().userRegister(
        data: data,
        token: token!,
      );
      if (response.data?.responseCode == 200) {
        if (response.data?.data?.isRegistered == true) {
          await isRegistered(isRegistered: true);
          CommonSnackbar(
            text: response.data?.message ?? 'User registered successfully.',
          ).showToast();
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
          text: response.data?.message ?? 'Something went wrong',
        ).showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
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

  void generateVoter(String? value) {
    final upper = (value ?? '').toUpperCase();
    voterIdController.value = TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    aadharController.dispose();
    voterIdController.dispose();
    whathsappNoController.dispose();
    invitedByController.dispose();
    genderController.dispose();
    super.dispose();
  }
}
