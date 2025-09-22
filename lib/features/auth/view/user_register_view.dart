import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_image_widget.dart';
import 'package:inldsevak/features/auth/models/request/validate_otp_request_model.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/auth/view_model/user_register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/features/common_fields/widget/assembly_constituency_drop_down.dart';
import 'package:inldsevak/features/common_fields/widget/map_search_field.dart';
import 'package:inldsevak/features/common_fields/widget/map_search_location.dart';
import 'package:inldsevak/features/common_fields/widget/parliamentary_constituency_drop_down.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';

class UserRegisterView extends StatefulWidget {
  final OtpRequestModel data;
  const UserRegisterView({super.key, required this.data});

  @override
  State<UserRegisterView> createState() => _UserRegisterViewState();
}

class _UserRegisterViewState extends State<UserRegisterView>
    with DateAndTimePicker {
  final searchController = SingleSelectController<Predictions?>(null);
  final assemblyconstituencyController = SingleSelectController<Constituency>(
    null,
  );
  final parliamentaryconstituencyController =
      SingleSelectController<Constituency>(null);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    parliamentaryconstituencyController.dispose();
    assemblyconstituencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return PopScope(
      canPop: true,
      child: ChangeNotifierProvider(
        create: (context) => UserRegisterViewModel(),
        builder: (context, child) {
          final provider = context.read<UserRegisterViewModel>();
          return Scaffold(
            appBar: AuthUtils.appbar(title: localization.complete_your_profile),
            backgroundColor: context.cardColor,
            body: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.horizontalspacing,
              ),
              child: Consumer<UserRegisterViewModel>(
                builder: (_, _, _) {
                  return Form(
                    key: provider.userDetailsFormKey,
                    autovalidateMode: provider.autoValidateMode,
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
                          validator: (text) => text?.validateName(
                            argument: localization.name_validator,
                          ),
                        ),
                        // FormTextFormField(
                        //   isRequired: true,
                        //   headingText: localization.father_name,
                        //   hintText: localization.father_name,
                        //   focus: provider.fatherNameFocus,
                        //   nextFocus: provider.emailFocus,
                        //   prefixIcon: AppImages.userIcon,
                        //   controller: provider.fatherNameController,
                        //   keyboardType: TextInputType.name,
                        //   validator: (text) => text?.validateName(
                        //     argument: localization.father_name_validator,
                        //   ),
                        // ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.email,
                          hintText: "abc@gmail.com",
                          focus: provider.emailFocus,
                          // nextFocus: provider.wathsappFocus,
                          controller: provider.emailController,
                          prefixIcon: AppImages.emailIcon,
                          validator: (text) => text?.validateEmail(
                            argument: localization.email_validator,
                          ),
                        ),
                        // FormTextFormField(
                        //   isRequired: true,
                        //   headingText: localization.whatapp_no,
                        //   hintText: localization.enter_phone_number,
                        //   keyboardType: TextInputType.phone,
                        //   maxLength: 10,
                        //   focus: provider.wathsappFocus,
                        //   controller: provider.whathsappNoController,
                        //   prefixIcon: AppImages.phoneIcon,
                        //   validator: (text) => text?.validateNumber(
                        //     argument: localization.phone_validator,
                        //   ),
                        // ),
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
                              provider.dobController.text = userDateFormat(
                                date,
                              );
                              provider.companyDateFormat = companyDateFormat(
                                date,
                              );
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
                        MapSearchLocation(hintText: "hintText"),
                        // MapSearchField(
                        //   visibility: (boolean) {
                        //     if (boolean) {
                        //       _scrollController.animateTo(
                        //         _scrollController.position.maxScrollExtent /
                        //             1.8,
                        //         duration: Duration(milliseconds: 300),
                        //         curve: Curves.easeIn,
                        //       );
                        //       parliamentaryconstituencyController.clear();
                        //       assemblyconstituencyController.clear();
                        //     }
                        //   },
                        //   // searchController: searchController,
                        //   text: localization.address_details,
                        //   hintText: localization.eg_address,
                        // ),
                        ParliamentaryConstituencyDropDownWidget(
                          constituencyController:
                              parliamentaryconstituencyController,
                          onChange: (constituency) {
                            context
                                .read<ConstituencyViewModel>()
                                .getAssemblyConstituencies(
                                  id: constituency?.sId,
                                );
                          },
                        ),
                        AssemblyConstituencyDropDownWidget(
                          constituencyController:
                              assemblyconstituencyController,
                        ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.aadhaar_no,
                          hintText: "0000 0000 0000",
                          maxLength: 14,
                          controller: provider.aadharController,
                          prefixIcon: AppImages.aadharIcon,
                          keyboardType: TextInputType.number,
                          validator: (text) => text?.validateAadhar(
                            argument: localization.aadhar_validator,
                          ),
                          onChanged: (value) => provider.generateAadhar(value),
                        ),
                        UploadImageWidget(
                          title: localization.upload_aadhar,
                          onTap: () => provider.selectImage(isAadhar: true),
                          onRemoveTap: () =>
                              provider.removeImage(isAadhar: true),
                          imageFile: provider.aadharImage,
                        ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.voter_id,
                          hintText: "ABC1234567",
                          maxLength: 10,
                          controller: provider.voterIdController,
                          prefixIcon: AppImages.aadharIcon,
                          keyboardType: TextInputType.text,
                          validator: (text) => text?.validateVoterID(
                            argument: localization.voter_id_validator,
                          ),
                          onChanged: (value) => provider.generateVoter(value),
                        ),
                        UploadImageWidget(
                          title: localization.upload_voter_id,
                          onTap: () => provider.selectImage(isAadhar: false),
                          onRemoveTap: () =>
                              provider.removeImage(isAadhar: false),
                          imageFile: provider.voterIdImage,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar:
                Consumer2<UserRegisterViewModel, MapSearchViewModel>(
                  builder: (context, value, search, _) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.horizontalspacing,
                        vertical: Dimens.verticalspacing,
                      ),
                      child: CommonButton(
                        isEnable: !value.isLoading,
                        isLoading: value.isLoading,
                        text: localization.register,
                        onTap: () async {
                          await provider.registerUserDetails(
                            addressModel: search.addressModel,
                            assemblyConstituenciesID:
                                assemblyconstituencyController.value?.sId,
                            parliamentaryConstituenciesID:
                                parliamentaryconstituencyController.value?.sId,
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
