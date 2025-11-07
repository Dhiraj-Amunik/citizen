import 'dart:developer';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/model/request_volunteer_model.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/services/volunterr_repository.dart';
import 'package:quickalert/quickalert.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart'
    as mla;
import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as profile;

class BeAVolunteerViewModel extends BaseViewModel {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final fullNameController = TextEditingController();
  final nameFocus = FocusNode();
  final emailController = TextEditingController();
  final emailFocus = FocusNode();
  final phoneNumberController = TextEditingController();
  final phoneNumberFocus = FocusNode();
  final ageController = TextEditingController();
  final ageFocus = FocusNode();
  final genderController = SingleSelectController<String>(null);
  final occupationController = SingleSelectController<String>(null);
  final SingleSelectController<mla.Data> mlaController =
      SingleSelectController<mla.Data>(null);
  final occupationFocus = FocusNode();
  final addressController = TextEditingController();
  final addressFocus = FocusNode();
  final Map<String, bool> _selectedInterest = {};
  Map<String, bool> get selectedInterest => _selectedInterest;
  set selectedInterest(Map<String, bool> value) {
    selectedInterestList.clear();
    _selectedInterest.addAll(value);
    _selectedInterest.forEach((key, value) {
      if (value) {
        selectedInterestList.add(key);
      }
    });
  }

  final preferredTimeSlotsController = SingleSelectController<String>(null);
  final hoursPerWeekController = SingleSelectController<String>(null);

  List<String> genderList = ['Male', 'Female', 'others'];
  List<String> occupationList = ['Teacher', 'Engineer', 'Social Worker'];
  List<String> timeSlotsList = ['Morning', 'Afternoon', 'Evening'];
  List<String> hoursPerWeekList = ['1hrs', '2hrs', '3hrs'];
  List<String> interestsList = [
    'Community Events',
    'Social Welfare',
    'Healthcare',
    'Education Support',
    'Environmental',
  ];
  List<String> selectedInterestList = [];

  List<String> availability = ['Weekdays', 'Weekends', 'Anytime'];
  String? selectedAvailability;

  void selectAvailability(String? option) {
    selectedAvailability = option;
  }

  Future<void> creatNewVolunteer() async {
    if (formKey.currentState!.validate()) {
      autoValidateMode = AutovalidateMode.disabled;
    } else {
      autoValidateMode = AutovalidateMode.onUserInteraction;
      return;
    }

    isLoading = true;
    try {
      final data = RequestVolunteerModel(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneNumberController.text.trim(),
        age: ageController.text.trim(),
        gender: genderController.value!,
        occupation: occupationController.value!,
        address: "",
        areasOfInterest: selectedInterestList,
        availability: selectedAvailability!,
        preferredTimeSlot: preferredTimeSlotsController.value!,
        hoursPerWeek: hoursPerWeekController.value!,
        mlaId: mlaController.value!.sId!,
      );

      final response = await VolunterrRepository().createVolunteer(data, token);
      if (response.data?.responseCode == 200) {
        RouteManager.pop();
        CommonSnackbar(
          text:
              response.data?.message ??
              "Volunteer request sended successfully !",
        ).showAnimatedDialog(type: QuickAlertType.success);
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

  @override
  void dispose() {
    mlaController.dispose();
    super.dispose();
  }

  autoFillData(profile.Data? profile) {
    fullNameController.text = profile?.name ?? "";
    emailController.text = profile?.email ?? "";
    phoneNumberController.text = profile?.phone ?? "";
    genderController.value = profile?.gender ?? "";
  }

  clear() {
    mlaController.clear();
    fullNameController.clear();
    emailController.clear();
    phoneNumberController.clear();
    ageController.clear();
    genderController.clear();
    occupationController.clear();
    preferredTimeSlotsController.clear();
    hoursPerWeekController.clear();
  }
}
