import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
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
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/disclaimer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isVisible = false;
      final prefs = await SharedPreferences.getInstance();
      isVisible = prefs.getBool('disclaimer_dismissed') ?? true;

      Future<void> dismissNotice() async {
        RouteManager.pop();
        isVisible = await prefs.setBool('disclaimer_dismissed', false);
      }

      if (isVisible) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return DraggableSheetWidget(
              onCompleted: dismissNotice,
              radius: Dimens.radiusX4,
              backgroundColor: Colors.amber[50],
              size: 0.24,
              child: DisclaimerNotice(onDismiss: dismissNotice),
            );
          },
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
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
              SizeBox.sizeHX4,
              Image.asset(
                "assets/logo/login_image.png",
                width: 200.spMax,
                height: 200.spMax,
              ),
              SizeBox.sizeHX6,
              Text(
                localization.login_or_signup,
                style: textTheme.headlineSmall?.copyWith(height: 0),
              ),
              Text(
                localization.hello_welcome_to_your_account,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPalettes.lightTextColor,
                  height: 0,
                ),
              ),
              SizeBox.sizeHX4,
              Consumer<LoginViewModel>(
                builder: (context, value, _) {
                  return Form(
                    key: loginFormKey,
                    autovalidateMode: provider.autoValidateMode,
                    child: Column(
                      spacing: Dimens.widgetSpacing,
                      children: [
                        Column(
                          spacing: Dimens.widgetSpacing,
                          children: [
                            CommonTextFormField(
                              backgroundColor: AppPalettes.liteGreenColor,
                              prefixIcon: AppImages.phoneIcon,
                              controller: provider.numberController,
                              hintText: localization.mobile_number,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              validator: (value) => value?.validateNumber(
                                argument: localization.phone_validator,
                              ),
                            ),
                            CommonButton(
                              isEnable: !provider.isLoading,
                              isLoading: provider.isLoading,
                              text: localization.send_otp,
                              onTap: () {
                                provider.generateOTP(loginFormKey);
                              },
                            ),
                          ],
                        ),
                      ],
                    ).symmetricPadding(horizontal: Dimens.horizontalspacing),
                  );
                },
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
