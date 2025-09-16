import 'package:flutter/cupertino.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/request/validate_otp_request_model.dart';
import 'package:inldsevak/features/auth/services/auth_repository.dart';
import 'package:quickalert/quickalert.dart';

class LoginViewModel extends BaseViewModel with CupertinoDialogMixin {
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final numberController = TextEditingController();
  final otpController = TextEditingController();

  Future<void> generateOTP(GlobalKey<FormState> loginFormKey) async {
    try {
      if (loginFormKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;
      final data = OtpRequestModel(phoneNo: numberController.text);
      final response = await AuthRepository().generateOTP(data);

      if (response.data?.responseCode == 200) {
        RouteManager.pushNamed(Routes.verifyOTPPage);
        CommonSnackbar(
          text: "${response.data?.data?.otp} is valid for 5 min",
        ).showSnackbar();
      } else {
        CommonSnackbar(text: response.error?.message).showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> resendOTP() async {
    try {
      RouteManager.pop();
      final data = OtpRequestModel(phoneNo: numberController.text);
      final response = await AuthRepository().generateOTP(data);

      if (response.data?.responseCode == 200) {
        CommonSnackbar(
          text: "${response.data?.data?.otp} is valid for 5 min",
        ).showSnackbar();
      } else {
        CommonSnackbar(text: response.error?.message).showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> verifyOtp() async {
    try {
      isLoading = true;
      final data = OtpRequestModel(
        phoneNo: numberController.text,
        otp: otpController.text,
      );
      final response = await AuthRepository().validateOTP(data);

      if (response.data?.responseCode == 200) {
        await setSecureStorage(
          setToken: response.data?.data?.token ?? '',
          phonenumber: data.phoneNo,
          isPartyMember: response.data?.data?.isPartyMember ?? false,
        );
        if (response.data?.data?.isRegistered == false) {
          RouteManager.pushNamed(Routes.userRegisterPage, arguments: data);
          return;
        } else {
          if (RouteManager.navigatorKey.currentState!.canPop()) {
            RouteManager.popUntilHome();
          }
        }

        CommonSnackbar(
          text: response.data?.message ?? 'Verified Successfully',
        ).showToast();
        clear();
      } else {
        CommonSnackbar(
          text: 'Invalid OTP Please try again later',
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      CommonSnackbar(
        text: "Something went wrong !",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  clear() {
    otpController.clear();
    numberController.clear();
    autoValidateMode = AutovalidateMode.disabled;
  }
}
