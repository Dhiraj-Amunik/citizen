import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/party_member/view_model/become_party_mem_view_model.dart';
import 'package:inldsevak/features/party_member/widgets/image_widget.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/complaints/model/response/constituency_model.dart'
    as constituency;
import 'package:inldsevak/features/party_member/model/response/parties_model.dart'
    as parties;

class BecomePartMemberView extends StatelessWidget with DateAndTimePicker {
  const BecomePartMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => BecomePartyMemViewModel(),
      builder: (context, _) {
        final provider = context.read<BecomePartyMemViewModel>();

        return Consumer<BecomePartyMemViewModel>(
          builder: (context, value, _) {
            return Scaffold(
              appBar: commonAppBar(
                center: false,
                elevation: 2,
                title: localization.become_part_mem,
              ),
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
                                    FormCommonDropDown<parties.Data>(
                                      heading: localization.party,
                                      controller: provider.partiesController,
                                      items: provider.partiesLists,
                                      hintText: localization.select_yout_party,
                                      listItemBuilder: (p0, parties, p2, p3) {
                                        return Text(
                                          "${parties.name}",
                                          style: context.textTheme.bodySmall,
                                        );
                                      },
                                      headerBuilder: (p0, parties, p2) {
                                        return Text(
                                          "${parties.name}",
                                          style: context.textTheme.bodySmall,
                                        );
                                      },
                                      validator: (text) =>
                                          text.toString().validateDropDown(
                                            argument:
                                                "      Please select a Party to join as  a member",
                                          ),
                                    ),
                                    FormTextFormField(
                                      headingText: localization.full_name,
                                      hintText:
                                          localization.enter_your_full_name,
                                      controller: provider.fullNameController,
                                      keyboardType: TextInputType.name,
                                      validator: (text) => text?.validate(
                                        argument: "Please enter your name",
                                      ),
                                    ),
                                    FormTextFormField(
                                      headingText: localization.father_name,
                                      hintText: localization.enter_parent_name,
                                      controller: provider.parentNameController,
                                      keyboardType: TextInputType.name,
                                      validator: (text) => text?.validate(
                                        argument: "Please enter parent name",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (provider.visibility)
                                SizedBox(height: Dimens.textFromSpacing),
                              FormTextFormField(
                                // enabled: !provider.visibility,
                                headingText: localization.mobile_number,
                                hintText: localization.enter_mobile_number,
                                controller: provider.mobileNumberController,
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value?.validateNumber(
                                  argument: "Enter valid 10 digits number",
                                ),
                                // onComplete: () => provider.getUserDetails(),
                              ),

                              SizedBox(height: Dimens.textFromSpacing),
                              Visibility(
                                visible: provider.visibility,
                                child: Column(
                                  spacing: Dimens.textFromSpacing,
                                  children: [
                                    FormTextFormField(
                                      headingText: localization.date_of_birth,
                                      hintText: localization.dd_mm_yyyy,
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
                                        argument: localization
                                            .date_of_birth_validator,
                                      ),
                                    ),
                                    FormCommonDropDown<String>(
                                      heading: localization.gender,
                                      controller: provider.genderController,
                                      items: provider.gendersList,
                                      hintText: localization.select_gender,
                                      validator: (text) =>
                                          text.toString().validateDropDown(
                                            argument: "     Select your Gender",
                                          ),
                                    ),
                                    FormCommonDropDown<String>(
                                      heading: localization.marital_status,
                                      controller:
                                          provider.maritalStatusController,
                                      items: provider.maritalStatusList,
                                      hintText: localization.select_status,
                                      validator: (text) =>
                                          text.toString().validateDropDown(
                                            argument:
                                                "     Select your marital status",
                                          ),
                                    ),
                                    FormCommonDropDown<constituency.Data>(
                                      heading: localization.constituency,
                                      controller:
                                          provider.constituencyController,
                                      items: provider.constituencyLists,
                                      hintText:
                                          localization.select_your_constituency,
                                      listItemBuilder:
                                          (p0, constituency, p2, p3) {
                                            return Text(
                                              "${constituency.name}",
                                              style:
                                                  context.textTheme.bodySmall,
                                            );
                                          },
                                      headerBuilder: (p0, constituency, p2) {
                                        return Text(
                                          "${constituency.name}",
                                          style: context.textTheme.bodySmall,
                                        );
                                      },
                                      validator: (text) =>
                                          text.toString().validateDropDown(
                                            argument:
                                                "     Select your constituency",
                                          ),
                                    ),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localization.photography,
                                          style: context.textTheme.bodySmall,
                                        ).onlyPadding(bottom: Dimens.gapX1B),
                                        Consumer<BecomePartyMemViewModel>(
                                          builder: (context, value, _) {
                                            return ImageWidget(
                                              onTap: () =>
                                                  provider.selectImage(),
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
                                      hintText:
                                          localization.explain_why_join_party,
                                      controller: provider.reasonController,
                                      maxLength: 150,
                                      maxLines: 5,
                                      validator: (text) => text?.validate(
                                        argument:
                                            "Please enter reason for joining our party",
                                      ),
                                    ),
                                    FormCommonDropDown<String>(
                                      heading: localization.preferred_role,
                                      controller: provider.roleController,
                                      items: provider.rolesList,
                                      hintText: localization.enter_your_role,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          .symmetricPadding(
                            horizontal: Dimens.horizontalspacing,
                          )
                          .onlyPadding(top: Dimens.verticalspacing),
                ),
              ),
              bottomNavigationBar:
                  CommonButton(
                        isAnimationEnable: provider.isEnable,
                        isEnable: provider.isEnable,
                        isLoading: provider.isLoading,
                        text: localization.submit_application,
                        onTap: () => provider.submitApplication(),
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
