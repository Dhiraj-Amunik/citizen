import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/auth/models/request/validate_otp_request_model.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';
import 'package:inldsevak/features/common_fields/view_model/search_view_model.dart';
import 'package:inldsevak/features/auth/view_model/user_register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/features/common_fields/widget/constituency_drop_down.dart';
import 'package:inldsevak/features/common_fields/widget/map_search_field.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/complaints/model/response/constituency_model.dart'
    as constituency;

class UserRegisterView extends StatefulWidget {
  final OtpRequestModel data;
  const UserRegisterView({super.key, required this.data});

  @override
  State<UserRegisterView> createState() => _UserRegisterViewState();
}

class _UserRegisterViewState extends State<UserRegisterView>
    with DateAndTimePicker {
  final searchController = SingleSelectController<Predictions?>(null);
  final constituencyController = SingleSelectController<constituency.Data>(
    null,
  );
  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider(
        create: (context) => UserRegisterViewModel(),
        builder: (context, child) {
          final provider = context.read<UserRegisterViewModel>();
          return Scaffold(
            appBar: AuthUtils.appbar(title: localization.complete_your_profile),
            backgroundColor: context.cardColor,
            body: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.horizontalspacing,
              ),
              child: Form(
                key: provider.userDetailsFormKey,
                autovalidateMode: context
                    .watch<UserRegisterViewModel>()
                    .autoValidateMode,
                child: Column(
                  spacing: Dimens.textFromSpacing,
                  children: [
                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.name,
                      hintText: localization.name,
                      focus: provider.nameFocus,
                      nextFocus: provider.emailFocus,
                      prefixIcon: AppImages.userIcon,

                      controller: provider.nameController,
                      keyboardType: TextInputType.name,
                      validator: (text) =>
                          text?.validate(argument: localization.name_validator),
                    ),
                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.email,
                      hintText: "abc@gmail.com",
                      focus: provider.emailFocus,
                      controller: provider.emailController,
                      prefixIcon: AppImages.emailIcon,
                      validator: (text) => text?.validateEmail(
                        argument: localization.email_validator,
                      ),
                    ),
                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.date_of_birth,
                      hintText: "01-01-2000",
                      controller: provider.dobController,
                      prefixIcon: AppImages.calenderIcon,
                      showCursor: false,
                      onTap: () async {
                        final date = await customDatePicker();
                        if (date != null) {
                          provider.dobController.text = userDateFormat(date);
                          provider.companyDateFormat = companyDateFormat(date);
                        }
                      },
                      keyboardType: TextInputType.none,
                      validator: (text) => text?.validate(
                        argument: localization.date_of_birth_validator,
                      ),
                    ),
                    FormCommonDropDown<String>(
                      isRequired: true,
                      heading: localization.gender,
                      hintText: localization.select_gender,
                      prefixIcon: AppImages.genderIcon,
                      controller: provider.genderController,
                      items: provider.genderList,
                      validator: (text) => text.toString().validateDropDown(
                        argument: localization.gender_validator,
                      ),
                    ),
                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.aadhaar_no,
                      hintText: "0000 0000 0000",
                      maxLength: 14,
                      controller: provider.aadharController,
                      prefixIcon: AppImages.aadharIcon,
                      keyboardType: TextInputType.number,
                      validator: (text) => text?.validate(
                        argument: localization.aadhar_validator,
                      ),
                      onChanged: (value) => provider.generateAadhar(value),
                    ),
                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.voter_id,
                      hintText: "ABC1234567",
                      maxLength: 10,
                      controller: provider.aadharController,
                      prefixIcon: AppImages.aadharIcon,
                      keyboardType: TextInputType.name,
                      validator: (text) => text?.validate(
                        argument: localization.aadhar_validator,
                      ),
                    ),
                    MapSearchField(
                      searchController: searchController,
                      text: localization.address_details,
                      hintText: localization.eg_address,
                    ),
                    ConstituencyDropDownWidget(
                      constituencyController: constituencyController,
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar:
                Consumer2<UserRegisterViewModel, SearchViewModel>(
                  builder: (context, value, search, _) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.horizontalspacing,
                        vertical: Dimens.verticalspacing,
                      ),
                      child: CommonButton(
                        isEnable: !value.isLoading,
                        isLoading: value.isLoading,
                        text: "Register",
                        onTap: () {
                          provider.registerUserDetails(
                            address: searchController.value?.description,
                            location: search.latlong,
                          );
                        },
                      ),
                    );
                  },
                ),
          );
        },
      ),
    );
  }
}
