import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/common_fields/widget/mla_drop_down.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/view_model/be_a_volunteer_view_model.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/widgets/availability_options_widget.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/widgets/interest_choice_widget.dart';
import 'package:provider/provider.dart';

class BeAVolunteerView extends StatelessWidget {
  const BeAVolunteerView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileViewModel>().profile;

    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => BeAVolunteerViewModel(),
      builder: (contextP, _) {
        final provider = contextP.read<BeAVolunteerViewModel>();
        provider.autoFillData(profileProvider);
        return Scaffold(
          appBar: commonAppBar(title: localization.be_a_volunteer),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
            child: Consumer<BeAVolunteerViewModel>(
              builder: (context, value, _) {
                return Form(
                  key: provider.formKey,
                  autovalidateMode: value.autoValidateMode,
                  child: Column(
                    spacing: Dimens.textFromSpacing,
                    children: [
                      MlaDropDownWidget(mlaController: provider.mlaController),
                      FormTextFormField(
                        isRequired: true,
                        focus: provider.nameFocus,
                        nextFocus: provider.emailFocus,
                        controller: provider.fullNameController,
                        hintText: localization.enter_your_name,
                        headingText: localization.name,
                        keyboardType: TextInputType.name,
                        validator: (text) => text?.validateName(
                          argument: localization.name_validator,
                        ),
                      ),
                      FormTextFormField(
                        isRequired: true,
                        focus: provider.emailFocus,
                        nextFocus: provider.phoneNumberFocus,
                        controller: provider.emailController,
                        hintText: localization.enter_email,
                        headingText: localization.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (text) => text?.validateEmail(
                          argument: localization.email_validator,
                        ),
                      ),
                      FormTextFormField(
                        isRequired: true,
                        focus: provider.phoneNumberFocus,
                        nextFocus: provider.ageFocus,
                        controller: provider.phoneNumberController,
                        hintText: localization.enter_phone_number,
                        headingText: localization.phone_number,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (text) => text?.validateNumber(
                          argument: localization.phone_validator,
                        ),
                      ),
                      FormTextFormField(
                        isRequired: true,
                        focus: provider.ageFocus,
                        controller: provider.ageController,
                        hintText: localization.enter_age,
                        headingText: localization.age,
                        keyboardType: TextInputType.number,
                        validator: (text) => text?.validate(
                          argument: localization.age_validator,
                        ),
                      ),
                      FormCommonDropDown<String>(
                        isRequired: true,
                        heading: localization.gender,
                        hintText: localization.select_gender,
                        items: provider.genderList,
                        controller: provider.genderController,
                        validator: (text) => text.toString().validateDropDown(
                          argument: localization.gender_validator,
                        ),
                      ),
                      FormCommonDropDown<String>(
                        isRequired: true,
                        heading: localization.occupation,
                        hintText: localization.enter_occupation,
                        items: provider.occupationList,
                        controller: provider.occupationController,
                        validator: (text) => text.toString().validateDropDown(
                          argument: localization.occupation_validator,
                        ),
                      ),

                      FormCommonChild(
                        isRequired: true,
                        heading: localization.area_of_interest,
                        child: InterestChoiceWidget(
                          options: provider.interestsList,
                          onSelectionChanged: (selected) =>
                              provider.selectedInterest = selected,
                        ),
                      ),
                      FormCommonChild(
                        isRequired: true,
                        heading: localization.availability,
                        child: AvailabilityOptionsWidgets(
                          options: provider.availability,
                          onOptionSelected: (option) {
                            provider.selectAvailability(option);
                          },
                        ),
                      ),
                      FormCommonDropDown<String>(
                        isRequired: true,
                        heading: localization.preferred_time_slots,
                        hintText: localization.select_time_slot,
                        items: provider.timeSlotsList,
                        controller: provider.preferredTimeSlotsController,
                        validator: (text) => text.toString().validateDropDown(
                          argument: localization.time_slot_validator,
                        ),
                      ),
                      FormCommonDropDown<String>(
                        isRequired: true,
                        heading: localization.hours_per_week,
                        hintText: localization.select_hours,
                        items: provider.hoursPerWeekList,
                        controller: provider.hoursPerWeekController,
                        validator: (text) => text.toString().validateDropDown(
                          argument: localization.hours_per_week_validator,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar:
              Row(
                    spacing: Dimens.gapX3,
                    children: [
                      CommonButton(
                        onTap: () => provider.clear(),
                        color: AppPalettes.whiteColor,
                        borderColor: AppPalettes.primaryColor,
                        textColor: AppPalettes.primaryColor,
                        text: localization.clear,
                        fullWidth: false,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.paddingX6,
                          vertical: Dimens.paddingX3,
                        ),
                      ),
                      Expanded(
                        child: Consumer<BeAVolunteerViewModel>(
                          builder: (context, value, _) {
                            return CommonButton(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.paddingX3,
                                vertical: Dimens.paddingX3,
                              ),
                              isEnable: !value.isLoading,
                              isLoading: value.isLoading,
                              text: localization.become_a_volunteer,
                              onTap: () => value.creatNewVolunteer(),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                  .symmetricPadding(horizontal: Dimens.horizontalspacing)
                  .onlyPadding(
                    top: Dimens.textFromSpacing,
                    bottom: Dimens.verticalspacing,
                  ),
        );
      },
    );
  }
}
