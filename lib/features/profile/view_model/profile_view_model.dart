import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as model;
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/request/user_register_request_model.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/profile/services/profile_repository.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:provider/provider.dart';

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
  final voterIdController = TextEditingController();
  Constituency? parlimentaryConstituencyData;
  Constituency? assemblyConstituencyData;

  List<String> genderList = ['Male', 'Female', 'others'];
  String? gender;

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
    AddressModel? addressModel,
    String? genderValue,
    String? assemblyConstituenciesID,
    String? parliamentaryConstituenciesID,
  }) async {
    try {
      if (!userDetailsFormKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }

      isLoading = true;

      final data = RequestRegisterModel();
      bool needUpdate = false;
      if (nameController.text != profile?.name) {
        data.name = nameController.text;
        needUpdate = true;
      }

      if (emailController.text != profile?.email) {
        needUpdate = true;
        data.email = emailController.text;
      }
      if (dobController.text != profile?.dateOfBirth) {
        needUpdate = true;
        data.dateOfBirth = companyDateFormat;
      }

      if (genderValue?.toLowerCase() != profile?.gender?.toLowerCase()) {
        needUpdate = true;
        data.gender = genderValue?.toLowerCase();
      }

      if (assemblyConstituenciesID != profile?.assemblyConstituency?.sId ||
          parliamentaryConstituenciesID !=
              profile?.parliamentryConstituency?.sId) {
        needUpdate = true;
        data.parliamentaryId = parliamentaryConstituenciesID;

        data.assemblyId = assemblyConstituenciesID;
      }

      if (profile?.document?.isEmpty == true ||
          aadharController.text != getInitialDocumentNumber('aadhaar')) {
        needUpdate = true;
        data.document = [
          Document(
            documentType: 'aadhaar',
            documentNumber: aadharController.text,
            documentUrl: "",
          ),
        ];
      }

      if (profile?.document?.isEmpty == true ||
          voterIdController.text != getInitialDocumentNumber('voterid')) {
        needUpdate = true;
        data.document = [
          ...data.document ?? [],
          Document(
            documentType: 'voterId',
            documentNumber: voterIdController.text,
            documentUrl: "",
          ),
        ];
      }

      if (addressModel != null) {
        needUpdate = true;

        if (addressModel.formattedAddress != profile?.address) {
          data.address = addressModel.formattedAddress;
        }
        if (addressModel.city != profile?.city) {
          data.city = addressModel.city;
        }
        if (addressModel.district != profile?.district) {
          data.district = addressModel.district;
        }
        if (addressModel.state != profile?.state) {
          data.state = addressModel.state;
        }
        if (addressModel.pincode != profile?.pincode) {
          data.pincode = addressModel.pincode;
        }
        data.location = Location(
          coordinates: [addressModel.latitude, addressModel.longitude],
        );
      }
      if (needUpdate == false) {
        CommonSnackbar(text: "Please edit profile to update").showToast();
        return;
      }
      final response = await ProfileRepository().updateUserProfile(
        token: token!,
        data: data,
      );
      if (response.data?.responseCode == 200) {
        await getUserProfile();
        CommonSnackbar(text: "Profile updated successfully").showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  loadProfile() async {
    try {
      nameController.text = profile?.name ?? "";
      if (profile?.gender != "" &&
          profile?.gender != null &&
          profile?.gender?.isNotEmpty == true) {
        gender = profile?.gender?.capitalize().trim();
      }
      emailController.text = profile?.email ?? "";
      phoneNumberController.text = profile?.phone ?? "";
      dobController.text = companyDateFormat?.toDdMmYyyy() ?? "";

      if (profile?.document != null && profile?.document?.isNotEmpty == true) {
        profile?.document?.forEach((document) {
          if (document.documentType?.toLowerCase() == "aadhaar") {
            aadharController.text = document.documentNumber.toString();
          }
          if (document.documentType?.toLowerCase() == "voterid") {
            voterIdController.text = document.documentNumber.toString();
          }
        });
      }
      address = AddressModel(
        formattedAddress: profile?.address ?? "",
        city: profile?.city ?? "",
        district: profile?.district ?? "",
        state: profile?.state ?? "",
        pincode: profile?.pincode ?? "",
        latitude: profile?.location?.coordinates?.first ?? 0.0,
        longitude: profile?.location?.coordinates?.last ?? 0.0,
      );
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

  void generateVoter(String? value) {
    voterIdController.value = TextEditingValue(text: value!.toUpperCase());
  }

  void generateAadhar(String? value) {
    // Remove all spaces first
    String digitsOnly = value!.replaceAll(RegExp(r'\s+'), '');

    // Add spaces after every 4 characters
    String formattedValue = digitsOnly
        .replaceAllMapped(RegExp(r".{1,4}"), (match) => "${match.group(0)} ")
        .trim();
    aadharController.value = TextEditingValue(text: formattedValue);
  }

  String? getInitialDocumentNumber(String? docType) {
    return profile?.document
        ?.firstWhere((doc) => doc.documentType?.toLowerCase() == docType)
        .documentNumber;
  }
}
