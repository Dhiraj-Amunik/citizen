import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/common_pinput.dart';
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';
import 'package:inldsevak/features/auth/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

class VerifyOtpView extends StatelessWidget with CupertinoDialogMixin {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LoginViewModel>();
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        provider.otpController.clear();
      },
      child: Scaffold(
        appBar: AuthUtils.appbar(canPop: true),
        body: Column(
          spacing: Dimens.gapX2,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(localization.verify_otp, style: textTheme.headlineSmall),
                SizeBox.sizeHX1,
                Text(
                  localization.otp_description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppPalettes.lightTextColor,
                  ),
                ),
              ],
            ).symmetricPadding(horizontal: Dimens.horizontalspacing),

            SizeBox.size,
            CommonPinput(
              controller: provider.otpController,
              length: 4,
              margin: EdgeInsets.symmetric(horizontal: Dimens.marginX2),
              validator: (value) =>
                  value?.validateOTP(4, argument: "Invalid otp"),
            ),
            SizeBox.sizeHX1,
            Consumer<LoginViewModel>(
              builder: (context, value, _) {
                return CommonButton(
                  isLoading: provider.isLoading,
                  isEnable: !provider.isLoading,
                  text: localization.verify_otp,
                  onTap: () {
                    provider.verifyOtp();
                  },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Text(
                    localization.change_your_phone_no,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppPalettes.lightTextColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    customRightCupertinoDialog(
                      content:
                          "Resend Otp to ${provider.numberController.text}",
                      rightButton: "Resend Otp",
                      onTap: () => provider.resendOTP(),
                    );
                  },
                  child: Text(
                    localization.resend_otp,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppPalettes.primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            SizeBox.sizeHX3,
          ],
        ).horizontalPadding(Dimens.horizontalspacing),
      ),
    );
  }
}
