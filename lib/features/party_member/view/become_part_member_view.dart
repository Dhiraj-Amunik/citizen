import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/common_fields/widget/assembly_constituency_drop_down.dart';
import 'package:inldsevak/features/party_member/view_model/become_party_mem_view_model.dart';
import 'package:inldsevak/features/party_member/widgets/image_widget.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class BecomePartMemberView extends StatelessWidget with DateAndTimePicker {
  const BecomePartMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => BecomePartyMemViewModel(),
      builder: (context, _) {
        final profile = context.read<ProfileViewModel>();
        final provider = context.read<BecomePartyMemViewModel>();
        provider.autoFillData(profile.profile);

        return Consumer<BecomePartyMemViewModel>(
          builder: (context, value, _) {
            return Scaffold(
              appBar: commonAppBar(title: localization.become_part_mem),
              body: SingleChildScrollView(
                child: Form(
                  key: value.formKey,
                  autovalidateMode: provider.autoValidateMode,
                  child:
                      Column(
                        children: [
                          Visibility(
                            visible: provider.visibility,
                            child: Column(
                              spacing: Dimens.textFromSpacing,
                              children: [
                                FormTextFormField(
                                  isRequired: true,
                                  headingText: localization.full_name,
                                  hintText: localization.enter_your_full_name,
                                  nextFocus: provider.parentNameFocus,
                                  controller: provider.fullNameController,
                                  keyboardType: TextInputType.name,
                                  validator: (text) => text?.validateName(
                                    argument: "Please enter your name",
                                  ),
                                ),
                                FormTextFormField(
                                  isRequired: true,
                                  headingText: localization.parents_name,
                                  focus: provider.parentNameFocus,
                                  nextFocus: provider.mobileFocus,
                                  hintText: localization.enter_parent_name,
                                  controller: provider.parentNameController,
                                  keyboardType: TextInputType.name,
                                  validator: (text) => text?.validateName(
                                    argument: "Please enter parent name",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (provider.visibility)
                            SizedBox(height: Dimens.textFromSpacing),
                          FormTextFormField(
                            isRequired: true,
                            // enabled: !provider.visibility,
                            headingText: localization.mobile_number,
                            focus: provider.mobileFocus,
                            hintText: localization.enter_mobile_number,
                            controller: provider.mobileNumberController,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            validator: (value) => value?.validateNumber(
                              argument: "Enter valid 10 digits number",
                            ),
                            onChanged: (text) {
                              if (profile.profile?.phone != null &&
                                  profile.profile!.phone!.trim() == text) {
                                provider.autoFillData(profile.profile);
                              }
                            },
                          ),

                          SizedBox(height: Dimens.textFromSpacing),
                          Visibility(
                            visible: provider.visibility,
                            child: Column(
                              spacing: Dimens.textFromSpacing,
                              children: [
                                FormTextFormField(
                                  isRequired: true,
                                  headingText: localization.date_of_birth,
                                  hintText: localization.dd_mm_yyyy,
                                  keyboardType: TextInputType.none,
                                  controller: provider.dobController,
                                  suffixIcon: AppImages.calenderIcon,
                                  showCursor: false,
                                  onTap: () async {
                                    final date = await customDatePicker();
                                    if (date != null) {
                                      provider.dobController.text =
                                          userDateFormat(date);
                                      provider.companyDateFormat =
                                          companyDateFormat(date);
                                    }
                                  },
                                  validator: (text) => text?.validate(
                                    argument:
                                        localization.date_of_birth_validator,
                                  ),
                                ),
                                FormCommonDropDown<String>(
                                  isRequired: true,
                                  heading: localization.gender,
                                  controller: provider.genderController,
                                  items: provider.gendersList,
                                  hintText: localization.select_gender,
                                  validator: (text) =>
                                      text.toString().validateDropDown(
                                        argument: "Select your Gender",
                                      ),
                                ),
                                FormCommonDropDown<String>(
                                  isRequired: true,
                                  heading: localization.marital_status,
                                  controller: provider.maritalStatusController,
                                  items: provider.maritalStatusList,
                                  hintText: localization.select_status,
                                  validator: (text) =>
                                      text.toString().validateDropDown(
                                        argument: "Select your marital status",
                                      ),
                                ),
                                AssemblyConstituencyDropDownWidget(
                                  constituencyController:
                                      provider.constituencyController,
                                  initialData: profile.assemblyConstituencyData,
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localization.photography,
                                      style: context.textTheme.bodySmall,
                                    ).onlyPadding(bottom: Dimens.gapX1B),
                                    Consumer<BecomePartyMemViewModel>(
                                      builder: (context, value, _) {
                                        return ImageWidget(
                                          onTap: () => provider.selectImage(),
                                          onRemoveTap: () =>
                                              provider.removeImage(),
                                          imageFile:
                                              provider.photographyPicture,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                FormTextFormField(
                                  showCounterText: true,
                                  headingText:
                                      localization.reason_for_joining_party,
                                  hintText: localization.explain_why_join_party,
                                  controller: provider.reasonController,
                                  maxLength: 150,
                                  maxLines: 5,
                                  // validator: (text) => text?.validate(
                                  //   argument:
                                  //       "Please enter reason for joining our party",
                                  // ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).symmetricPadding(
                        horizontal: Dimens.horizontalspacing,
                        vertical: Dimens.paddingX2,
                      ),
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
                              horizontal: Dimens.paddingX8,
                              vertical: Dimens.paddingX3,
                            ),
                          ),
                          Expanded(
                            child: CommonButton(
                              padding: EdgeInsets.symmetric(
                                vertical: Dimens.paddingX3,
                              ),
                              isAnimationEnable: provider.isEnable,
                              isEnable: provider.isEnable,
                              isLoading: provider.isLoading,
                              text: localization.submit_application,
                              onTap: () => provider.submitApplication(
                                parlimentConstituencyID:
                                    profile.parlimentaryConstituencyData?.sId,
                              ),
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
      },
    );
  }
}
