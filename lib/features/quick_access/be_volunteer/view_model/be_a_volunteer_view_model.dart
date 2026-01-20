import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/model/request_volunteer_model.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/services/volunterr_repository.dart';
import 'package:inldsevak/features/volunter/view/top_volunteers_view.dart';
import 'package:inldsevak/l10n/general_stream.dart';
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
    notifyListeners(); // Notify to update UI if needed
  }

  final preferredTimeSlotsController = SingleSelectController<String>(null);
  final hoursPerWeekController = TextEditingController();
  double _hoursPerWeek = 0;
  double get hoursPerWeek => _hoursPerWeek;
  set hoursPerWeek(double value) {
    _hoursPerWeek = value;
    // Update text controller when value changes from slider
    final textValue = value.round().toString();
    if (hoursPerWeekController.text != textValue) {
      hoursPerWeekController.text = textValue;
    }
    notifyListeners();
  }
  

  // Original English lists (for API submission)
  final List<String> _genderList = ['Male', 'Female', 'Others'];
  final List<String> _occupationList = ['Teacher', 'Engineer', 'Social Worker','Student','Other'];
  final List<String> _timeSlotsList = ['Morning', 'Afternoon', 'Evening','Complete Day'];
  final List<String> _interestsList = [
    'Community Events',
    'Social Welfare',
    'Healthcare',
    'Education Support',
    'Environmental',
  ];
  final List<String> _availability = ['Weekdays', 'Weekends', 'Anytime'];

  // Translated lists (for UI display)
  List<String> get genderList {
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return _genderList;
    
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

  List<String> get occupationList {
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return _occupationList;
    
    return _occupationList.map((occupation) {
      switch (occupation.toLowerCase()) {
        case 'teacher':
          return 'शिक्षक';
        case 'engineer':
          return 'इंजीनियर';
        case 'social worker':
          return 'सामाजिक कार्यकर्ता';
        case 'student':
          return 'छात्र';
        case 'other':
          return 'अन्य';
        default:
          return occupation;
      }
    }).toList();
  }

  List<String> get timeSlotsList {
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return _timeSlotsList;
    
    return _timeSlotsList.map((slot) {
      switch (slot.toLowerCase()) {
        case 'morning':
          return 'सुबह';
        case 'afternoon':
          return 'दोपहर';
        case 'evening':
          return 'शाम';
        case 'complete day':
          return 'पूरा दिन';
        default:
          return slot;
      }
    }).toList();
  }

  List<String> get interestsList {
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return _interestsList;
    
    return _interestsList.map((interest) {
      switch (interest.toLowerCase()) {
        case 'community events':
          return 'सामुदायिक कार्यक्रम';
        case 'social welfare':
          return 'सामाजिक कल्याण';
        case 'healthcare':
          return 'स्वास्थ्य सेवा';
        case 'education support':
          return 'शिक्षा सहायता';
        case 'environmental':
          return 'पर्यावरण';
        default:
          return interest;
      }
    }).toList();
  }

  List<String> get availability {
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return _availability;
    
    return _availability.map((avail) {
      switch (avail.toLowerCase()) {
        case 'weekdays':
          return 'सप्ताह के दिन';
        case 'weekends':
          return 'सप्ताहांत';
        case 'anytime':
          return 'कभी भी';
        default:
          return avail;
      }
    }).toList();
  }

  List<String> selectedInterestList = [];

  // Helper methods to convert translated values back to English for API
  String? _getOriginalGenderValue(String? translatedValue) {
    if (translatedValue == null) return null;
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return translatedValue;
    
    switch (translatedValue) {
      case 'पुरुष':
        return 'Male';
      case 'महिला':
        return 'Female';
      case 'अन्य':
        return 'Others';
      default:
        return translatedValue;
    }
  }

  String? _getOriginalOccupationValue(String? translatedValue) {
    if (translatedValue == null) return null;
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return translatedValue;
    
    switch (translatedValue) {
      case 'शिक्षक':
        return 'Teacher';
      case 'इंजीनियर':
        return 'Engineer';
      case 'सामाजिक कार्यकर्ता':
        return 'Social Worker';
      case 'छात्र':
        return 'Student';
      case 'अन्य':
        return 'Other';
      default:
        return translatedValue;
    }
  }

  String? _getOriginalTimeSlotValue(String? translatedValue) {
    if (translatedValue == null) return null;
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return translatedValue;
    
    switch (translatedValue) {
      case 'सुबह':
        return 'Morning';
      case 'दोपहर':
        return 'Afternoon';
      case 'शाम':
        return 'Evening';
      case 'पूरा दिन':
        return 'Complete Day';
      default:
        return translatedValue;
    }
  }

  List<String> _getOriginalInterestValues(List<String> translatedValues) {
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return translatedValues;
    
    return translatedValues.map((interest) {
      switch (interest) {
        case 'सामुदायिक कार्यक्रम':
          return 'Community Events';
        case 'सामाजिक कल्याण':
          return 'Social Welfare';
        case 'स्वास्थ्य सेवा':
          return 'Healthcare';
        case 'शिक्षा सहायता':
          return 'Education Support';
        case 'पर्यावरण':
          return 'Environmental';
        default:
          return interest;
      }
    }).toList();
  }

  String? _getOriginalAvailabilityValue(String? translatedValue) {
    if (translatedValue == null) return null;
    final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
    if (!isHindiLocale) return translatedValue;
    
    switch (translatedValue) {
      case 'सप्ताह के दिन':
        return 'Weekdays';
      case 'सप्ताहांत':
        return 'Weekends';
      case 'कभी भी':
        return 'Anytime';
      default:
        return translatedValue;
    }
  }
  String? selectedAvailability;

  void selectAvailability(String? option) {
    selectedAvailability = option;
    notifyListeners(); // Notify to update UI if needed
  }

  String? validateHoursPerWeek(String? argument) {
    if (_hoursPerWeek <= 0) {
      return argument ?? "Please select hours per week";
    }
    return null;
  }

  Future<void> creatNewVolunteer() async {
    if (formKey.currentState!.validate()) {
      autoValidateMode = AutovalidateMode.disabled;
    } else {
      autoValidateMode = AutovalidateMode.onUserInteraction;
      return;
    }

    // Validate hours per week
    if (_hoursPerWeek <= 0) {
      autoValidateMode = AutovalidateMode.onUserInteraction;
      notifyListeners();
      return;
    }

    // Validate area of interest - at least one must be selected
    if (selectedInterestList.isEmpty) {
      autoValidateMode = AutovalidateMode.onUserInteraction;
      CommonSnackbar(
        text: "Please select at least one area of interest",
      ).showAnimatedDialog(type: QuickAlertType.warning);
      notifyListeners();
      return;
    }

    // Validate availability - must be selected
    if (selectedAvailability == null || selectedAvailability!.isEmpty) {
      autoValidateMode = AutovalidateMode.onUserInteraction;
      CommonSnackbar(
        text: "Please select your availability",
      ).showAnimatedDialog(type: QuickAlertType.warning);
      notifyListeners();
      return;
    }

    isLoading = true;
    try {
      // Convert translated values back to English for API
      final originalGender = _getOriginalGenderValue(genderController.value);
      final originalOccupation = _getOriginalOccupationValue(occupationController.value);
      final originalTimeSlot = _getOriginalTimeSlotValue(preferredTimeSlotsController.value);
      final originalInterests = _getOriginalInterestValues(selectedInterestList);
      final originalAvailability = _getOriginalAvailabilityValue(selectedAvailability);
      
      final data = RequestVolunteerModel(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneNumberController.text.trim(),
        age: ageController.text.trim(),
        gender: originalGender!,
        occupation: originalOccupation!,
        address: "",
        areasOfInterest: originalInterests,
        availability: originalAvailability!,
        preferredTimeSlot: originalTimeSlot!,
        hoursPerWeek: "${_hoursPerWeek.round()} Hours",
      );

      final response = await VolunterrRepository().createVolunteer(data, token);
      if (response.data?.responseCode == 200) {
        await CommonSnackbar(
          text: "Volunteer request is pending",
        ).showAnimatedDialog(
          type: QuickAlertType.success,
          onTap: () {
            // Use pushReplacementNamed instead of pushNamedAndRemoveAll
            // This replaces the volunteer form with topVolunteersPage,
            // so when user presses back, they go to the screen before the form
            RouteManager.pushReplacementNamed(
              Routes.topVolunteersPage,
              arguments: const TopVolunteersViewArgs(
                canApply: false,
                statusMessage: "Volunteer request is pending",
              ),
            );
          },
        );
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
    hoursPerWeekController.dispose();
    super.dispose();
  }

  autoFillData(profile.Data? profile) {
    fullNameController.text = profile?.name ?? "";
    emailController.text = profile?.email ?? "";
    phoneNumberController.text = profile?.phone ?? "";
    
    // Map profile gender to translated value if needed
    final profileGender = profile?.gender;
    if (profileGender != null) {
      final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
      if (isHindiLocale) {
        // Convert English to Hindi for display
        switch (profileGender.toLowerCase()) {
          case 'male':
            genderController.value = 'पुरुष';
            break;
          case 'female':
            genderController.value = 'महिला';
            break;
          case 'others':
            genderController.value = 'अन्य';
            break;
          default:
            genderController.value = profileGender;
        }
      } else {
        genderController.value = profileGender;
      }
    }
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
    _hoursPerWeek = 0;
    notifyListeners();
  }
}
