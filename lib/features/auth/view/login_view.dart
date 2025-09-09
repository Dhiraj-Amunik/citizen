import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';
import 'package:inldsevak/features/auth/utils/launch_url.dart';
import 'package:inldsevak/features/auth/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget with CupertinoDialogMixin {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<LoginViewModel>();
    onTap() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Scaffold(
        appBar: AuthUtils.appbar(),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/logo/login_image.png",
                width: 200.spMax,
                height: 200.spMax,
              ),
              SizeBox.sizeHX6,
              Text(
                "Login Or Signup",
                style: textTheme.headlineSmall?.copyWith(height: 0),
              ),
              Text(
                "Hello, welcome to your account",
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPalettes.lightTextColor,
                  height: 0,
                ),
              ),
              SizeBox.sizeHX4,
              Form(
                key: loginFormKey,
                autovalidateMode: provider.autoValidateMode,
                child: Column(
                  spacing: Dimens.widgetSpacing,
                  children: [
                    Consumer<LoginViewModel>(
                      builder: (context, value, _) {
                        return Column(
                          spacing: Dimens.widgetSpacing,
                          children: [
                            CommonTextFormField(
                              backgroundColor:
                                  AppPalettes.liteGreenTextFieldColor,
                              prefixIcon: AppImages.phoneIcon,
                              controller: provider.numberController,
                              hintText: localizations.mobile_number,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              validator: (value) => value?.validateNumber(
                                argument: localizations.phone_validator,
                              ),
                            ),
                            CommonButton(
                              isEnable: !provider.isLoading,
                              isLoading: provider.isLoading,
                              text: localizations.send_otp,
                              onTap: () {
                                provider.generateOTP(loginFormKey);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ).symmetricPadding(horizontal: Dimens.horizontalspacing),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.horizontalspacing,
          ),
          child: LaunchURL(),
        ),
      ),
    );
  }
}
