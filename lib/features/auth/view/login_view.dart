import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';
import 'package:inldsevak/features/auth/utils/launch_url.dart';
import 'package:inldsevak/features/auth/view_model/login_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/disclaimer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:inldsevak/core/widgets/common_button.dart';

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
      final prefs = await SharedPreferences.getInstance();

      // Show language selection popup only on first install
      // Check both language_selected flag AND language_code to ensure it's truly first install
      final languageSelected = prefs.getBool('language_selected') ?? false;
      final languageCode = prefs.getString('language_code');

      // Only show language selection if BOTH are missing (true first install)
      if (!languageSelected && languageCode == null) {
        // Set default to English if not already set
        await GeneralStream.instance.setLocale("en");

        // Show language selection dialog
        _showLanguageDialog(context, prefs);
      } else {
        // Language was already selected (either flag is set or language_code exists)
        // Sync the flag if language_code exists but flag is missing (edge case)
        if (languageCode != null && !languageSelected) {
          await prefs.setBool('language_selected', true);
        }
        // Show disclaimer if needed
        _showDisclaimerIfNeeded(context, prefs);
      }
    });
    super.initState();
  }

  void _showLanguageDialog(BuildContext context, SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must select a language
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(Dimens.paddingX4),
            decoration: BoxDecoration(
              color: AppPalettes.whiteColor,
              borderRadius: BorderRadius.circular(Dimens.paddingX4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizeBox.sizeHX5,
                Text(
                  "Select Language",
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizeBox.sizeHX3,
                CommonButton(
                  color: AppPalettes.whiteColor,
                  textColor: AppPalettes.blackColor,
                  text: "English",
                  borderColor: AppPalettes.primaryColor,
                  onTap: () async {
                    await GeneralStream.instance.setLocale("en");
                    await prefs.setBool('language_selected', true);
                    if (context.mounted) {
                      RouteManager.pop();
                      // Show disclaimer after language selection
                      _showDisclaimerIfNeeded(context, prefs);
                    }
                  },
                ),
                SizeBox.sizeHX3,
                CommonButton(
                  color: AppPalettes.whiteColor,
                  textColor: AppPalettes.blackColor,
                  text: "Hindi",
                  borderColor: AppPalettes.primaryColor,
                  onTap: () async {
                    await GeneralStream.instance.setLocale("hi");
                    await prefs.setBool('language_selected', true);
                    if (context.mounted) {
                      RouteManager.pop();
                      // Show disclaimer after language selection
                      _showDisclaimerIfNeeded(context, prefs);
                    }
                  },
                ),
                SizeBox.sizeHX5,
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDisclaimerIfNeeded(BuildContext context, SharedPreferences prefs) {
    bool isVisible = prefs.getBool('disclaimer_dismissed') ?? true;

    Future<void> dismissNotice() async {
      await prefs.setBool('disclaimer_dismissed', false);
    }

    if (isVisible && context.mounted) {
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
