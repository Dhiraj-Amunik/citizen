import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/donation/models/response/donation_history_model.dart';
import 'package:inldsevak/features/donation/services/donation_repository.dart';
import 'package:inldsevak/features/donation/models/request/donation_request_model.dart';

class DonationViewModel extends BaseViewModel {
  final amount = TextEditingController();
  final purpose = TextEditingController();

  final amountFocus = FocusNode();
  final purposeFocus = FocusNode();

  final GlobalKey<FormState> donationFormKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  List<Donations> pastDonations = [];

  @override
  Future<void> onInit() async {
    await getPastDonations();
    notifyListeners();
    return super.onInit();
  }

  Future<void> postDonation() async {
    try {
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
        purpose: purpose.text,
      );

      final response = await DonationRepository().postDonation(
        data: data,
        token: token!,
      );

      if (response.data?.responseCode == 200) {
        CommonSnackbar(
          text: response.data?.message ?? "Donation received successfully",
        ).showToast();

        await getPastDonations();
      } else {
        CommonSnackbar(text: "Unable to Donate!").showSnackbar();
      }
      clear();
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
    purpose.clear();
    autoValidateMode = AutovalidateMode.disabled;
  }
}
