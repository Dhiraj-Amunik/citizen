import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/view_model/be_a_volunteer_view_model.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/widgets/availability_options_widget.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/widgets/interest_choice_widget.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/widgets/hours_slider_widget.dart';
import 'package:inldsevak/l10n/general_stream.dart';
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

        // Check if Hindi keyboard might be shown (Hindi language)
        final isHindiLanguage =
            GeneralStream.instance.locale.languageCode == 'hi';
        // Hindi keyboard height is approximately 300px
        const hindiKeyboardHeight = 300.0;

        return Scaffold(
          appBar: commonAppBar(title: localization.be_a_volunteer),
          body: Builder(
            builder: (context) {
              // Check if any text field has focus (which would show Hindi keyboard)
              final hasFocus = FocusScope.of(context).hasFocus;
              final viewInsets = MediaQuery.of(context).viewInsets.bottom;
              // Show padding if system keyboard is showing OR if Hindi keyboard might be showing (Hindi mode + focus)
              final shouldShowKeyboardPadding =
                  isHindiLanguage && hasFocus && viewInsets == 0;

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: Dimens.horizontalspacing,
                  right: Dimens.horizontalspacing,
                  // Only add extra padding for Hindi locale, not for English
                  bottom: shouldShowKeyboardPadding
                      ? hindiKeyboardHeight
                      : viewInsets,
                ),
                child: Consumer<BeAVolunteerViewModel>(
                  builder: (context, value, _) {
                    return Form(
                      key: provider.formKey,
                      autovalidateMode: value.autoValidateMode,
                      child: Column(
                        spacing: Dimens.textFromSpacing,
                        children: [
                          FormTextFormField(
                            isRequired: true,
                            focus: provider.nameFocus,
                            nextFocus: provider.emailFocus,
                            controller: provider.fullNameController,
                            hintText: localization.enter_your_name,
                            headingText: localization.name,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                            enableSpeechInput: true,
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
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                            enableSpeechInput: true,
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
                            enableSpeechInput: true,
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
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
                            enableSpeechInput: true,
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                            keyboardType: TextInputType.number,
                            validator: (text) => text?.validate(
                              argument: localization.age_validator,
                            ),
                          ),
                          Consumer<BeAVolunteerViewModel>(
                            builder: (context, value, _) {
                              return FormCommonDropDown<String>(
                                key: ValueKey(
                                  'gender_${value.genderController.value}',
                                ),
                                isRequired: true,
                                heading: localization.gender,
                                hintText: localization.select_gender,
                                items: value.genderList,
                                controller: value.genderController,
                                onChanged: (selectedValue) {
                                  // CustomDropdown already updates the controller
                                  // Force Consumer to rebuild by accessing the view model
                                  final vm = context
                                      .read<BeAVolunteerViewModel>();
                                  vm.notifyListeners();
                                },
                                listItemBuilder: (context, item, _, __) {
                                  return TranslatedText(
                                    text: item,
                                    style: context.textTheme.bodySmall,
                                    disableTranslation: true,
                                  );
                                },
                                headerBuilder: (context, item, _) {
                                  return TranslatedText(
                                    text: item,
                                    style: context.textTheme.bodySmall,
                                    disableTranslation: true,
                                  );
                                },
                                validator: (text) =>
                                    text.toString().validateDropDown(
                                      argument: localization.gender_validator,
                                    ),
                              );
                            },
                          ),
                          FormCommonDropDown<String>(
                            isRequired: true,
                            heading: localization.occupation,
                            hintText: localization.enter_occupation,
                            items: provider.occupationList,
                            controller: provider.occupationController,
                            listItemBuilder: (context, item, _, __) {
                              return TranslatedText(
                                text: item,
                                style: context.textTheme.bodySmall,
                                disableTranslation: true,
                              );
                            },
                            headerBuilder: (context, item, _) {
                              return TranslatedText(
                                text: item,
                                style: context.textTheme.bodySmall,
                                disableTranslation: true,
                              );
                            },
                            validator: (text) =>
                                text.toString().validateDropDown(
                                  argument: localization.occupation_validator,
                                ),
                          ),
                          FormTextFormField(
                            isRequired: true,
                            focus: provider.addressFocus,
                            controller: provider.addressController,
                            hintText: localization.address,
                            headingText: localization.address,
                            enableSpeechInput: true,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                            keyboardType: TextInputType.text,
                            validator: (text) => text?.validate(
                              argument: localization.address_validator,
                            ),
                          ),
                          FormCommonChild(
                            isRequired: true,
                            heading: localization.area_of_interest,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InterestChoiceWidget(
                                  options: provider.interestsList,
                                  onSelectionChanged: (selected) =>
                                      provider.selectedInterest = selected,
                                ),
                                if (value.autoValidateMode ==
                                        AutovalidateMode.onUserInteraction &&
                                    value.selectedInterestList.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: Dimens.gapX1,
                                      left: Dimens.paddingX2,
                                    ),
                                    child: TranslatedText(
                                      text:
                                          "Please select at least one area of interest",
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppPalettes.redColor,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          FormCommonChild(
                            isRequired: true,
                            heading: localization.availability,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AvailabilityOptionsWidgets(
                                  options: provider.availability,
                                  onOptionSelected: (option) {
                                    provider.selectAvailability(option);
                                  },
                                ),
                                if (value.autoValidateMode ==
                                        AutovalidateMode.onUserInteraction &&
                                    (value.selectedAvailability == null ||
                                        value.selectedAvailability!.isEmpty))
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: Dimens.gapX1,
                                      left: Dimens.paddingX2,
                                    ),
                                    child: TranslatedText(
                                      text: "Please select your availability",
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppPalettes.redColor,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          FormCommonDropDown<String>(
                            isRequired: true,
                            heading: localization.preferred_time_slots,
                            hintText: localization.select_time_slot,
                            items: provider.timeSlotsList,
                            controller: provider.preferredTimeSlotsController,
                            listItemBuilder: (context, item, _, __) {
                              return TranslatedText(
                                text: item,
                                style: context.textTheme.bodySmall,
                                disableTranslation: true,
                              );
                            },
                            headerBuilder: (context, item, _) {
                              return TranslatedText(
                                text: item,
                                style: context.textTheme.bodySmall,
                                disableTranslation: true,
                              );
                            },
                            validator: (text) =>
                                text.toString().validateDropDown(
                                  argument: localization.time_slot_validator,
                                ),
                          ),
                          Consumer<BeAVolunteerViewModel>(
                            builder: (context, value, _) {
                              return FormField<double>(
                                initialValue: value.hoursPerWeek,
                                validator: (_) => value.validateHoursPerWeek(
                                  localization.hours_per_week_validator,
                                ),
                                builder: (field) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: Dimens.gapX1,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TranslatedText(
                                            text: localization.hours_per_week,
                                            style: context.textTheme.bodySmall,
                                          ),
                                          Text(
                                            ' *',
                                            style: context.textTheme.bodySmall,
                                          ),
                                        ],
                                      ).onlyPadding(bottom: Dimens.gapX1B),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: HoursSliderWidget(
                                              value: value.hoursPerWeek,
                                              onChanged: (newValue) {
                                                value.hoursPerWeek = newValue;
                                                field.didChange(newValue);
                                                field.validate();
                                              },
                                              min: 0,
                                              max: 160,
                                            ),
                                          ),
                                          SizedBox(width: Dimens.gapX2),
                                          SizedBox(
                                            width: 100.width(),
                                            child: FormTextFormField(
                                              controller:
                                                  value.hoursPerWeekController,
                                              hintText: "0",
                                              showDefaultSuffix: false,
                                              keyboardType:
                                                  TextInputType.number,
                                              textStyle: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        AppPalettes.blackColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                              borderColor:
                                                  AppPalettes.transparentColor,
                                              fillColor:
                                                  AppPalettes.liteGreenColor,
                                              radius: Dimens.radiusX3,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal:
                                                        Dimens.paddingX2,
                                                    vertical: Dimens.paddingX2,
                                                  ),
                                              maxLength: 3,
                                              suffixWidget: Padding(
                                                padding: EdgeInsets.only(
                                                  top: Dimens.paddingX3,
                                                  bottom: Dimens.paddingX3,
                                                ),
                                                child: TranslatedText(
                                                  text: "hours",
                                                  style: context
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: AppPalettes
                                                            .primaryColor,
                                                      ),
                                                ),
                                              ),
                                              onChanged: (text) {
                                                if (text != null &&
                                                    text.isNotEmpty) {
                                                  final hours =
                                                      double.tryParse(text) ??
                                                      0;
                                                  value.hoursPerWeek = hours
                                                      .clamp(0, 160);
                                                } else {
                                                  value.hoursPerWeek = 0;
                                                }
                                                field.didChange(
                                                  value.hoursPerWeek,
                                                );
                                                field.validate();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (field.hasError)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: Dimens.gapX1,
                                            left: Dimens.paddingX2,
                                          ),
                                          child: Text(
                                            field.errorText ??
                                                localization
                                                    .hours_per_week_validator,
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: AppPalettes.redColor,
                                                ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          bottomNavigationBar: SafeArea(
            child:
                Row(
                      spacing: Dimens.gapX3,
                      children: [
                        CommonButton(
                          onTap: () =>
                              contextP.read<BeAVolunteerViewModel>().clear(),
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
          ),
        );
      },
    );
  }
}
