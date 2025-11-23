import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/donation/models/response/donation_history_model.dart';
import 'package:inldsevak/features/donation/services/donation_repository.dart';
import 'package:inldsevak/features/donation/models/request/donation_request_model.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationViewModel extends BaseViewModel {
  final amount = TextEditingController();
  // final purpose = TextEditingController();

  final amountFocus = FocusNode();
  // final purposeFocus = FocusNode();

  final GlobalKey<FormState> donationFormKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  List<Donations> pastDonations = [];

  bool _isUpiSelected = false;
  bool get isUpiSelected => _isUpiSelected;
  set isUpiSelected(bool value) {
    _isUpiSelected = value;
    _isNetSelected = false;
    notifyListeners();
  }

  bool _isNetSelected = false;
  bool get isNetSelected => _isNetSelected;
  set isNetSelected(bool value) {
    _isNetSelected = value;
    _isUpiSelected = false;
    notifyListeners();
  }

  // @override
  // Future<void> onInit() async {
  //   await getPastDonations();
  //   notifyListeners();
  //   return super.onInit();
  // }

  Future<bool> manualDonation() async {
    try {
      // First validate the form - this will show validation errors if amount is empty or invalid
      if (!donationFormKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return false;
      }
      
      // If validation passes, disable auto-validate mode
      autoValidateMode = AutovalidateMode.disabled;
      
      // Check if amount is empty (should not happen if validation passed, but double-check)
      if (amount.text.trim().isEmpty) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return false;
      }

      // Check if payment option is selected
      if (!(isUpiSelected || isNetSelected)) {
        CommonSnackbar(
          text: "Please select one payment option",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return false;
      }
    } catch (err) {
      return false;
    }
    return true;
  }

  Future<void> postDonation() async {
    try {
      isLoading = true;
      if (donationFormKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      isLoading = true;

      final data = DonationRequestModel(
        amount: amount.text,
        // purpose: purpose.text,
      );
      final url =
          'upi://pay?pa=9988090768m@pnb&pn=INDIAN NATIONAL LOKDAL&am=${amount.text}&cu=INR';
      if (await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        final response = await DonationRepository().postDonation(
          data: data,
          token: token!,
        );

        if (response.data?.responseCode == 200) {
          // CommonSnackbar(
          //   text: response.data?.message ?? "Donation received successfully",
          // ).showToast();

          await getPastDonations();
        } else {
          CommonSnackbar(text: "Unable to Donate!").showSnackbar();
        }
        clear();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> getPastDonations() async {
    try {
      isLoading = true;
      final response = await DonationRepository().pastDonations(token: token!);

      if (response.data?.responseCode == 200) {
        pastDonations = List<Donations>.from(
          response.data?.data?.donations as List,
        );
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  clear() {
    amount.clear();
    // purpose.clear();
    autoValidateMode = AutovalidateMode.disabled;
  }
}
