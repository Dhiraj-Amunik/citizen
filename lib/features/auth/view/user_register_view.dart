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
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/auth/view_model/user_register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/features/common_fields/widget/assembly_constituency_drop_down.dart';
import 'package:inldsevak/features/common_fields/widget/map_search_location.dart';
import 'package:inldsevak/features/common_fields/widget/parliamentary_constituency_drop_down.dart';
import 'package:inldsevak/l10n/general_stream.dart';
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
  final assemblyconstituencyController = SingleSelectController<Constituency>(
    null,
  );
  final parliamentaryconstituencyController =
      SingleSelectController<Constituency>(null);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    parliamentaryconstituencyController.dispose();
    assemblyconstituencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final constituencyProvider = context.read<ConstituencyViewModel>();
    final mapsProvider = context.read<MapSearchViewModel>();

    return PopScope(
      canPop: true,
      child: ChangeNotifierProvider(
        create: (context) => UserRegisterViewModel(),
        builder: (context, child) {
          final provider = context.read<UserRegisterViewModel>();
          return Scaffold(
            appBar: AuthUtils.appbar(title: localization.complete_your_profile),
            backgroundColor: context.cardColor,
            body: Builder(
              builder: (context) {
                // Check if Hindi keyboard might be shown (Hindi language)
                final isHindiLanguage = GeneralStream.instance.locale.languageCode == 'hi';
                // Hindi keyboard height is approximately 300px
                const hindiKeyboardHeight = 300.0;
                
                // Check if any text field has focus (which would show Hindi keyboard)
                final hasFocus = FocusScope.of(context).hasFocus;
                final viewInsets = MediaQuery.of(context).viewInsets.bottom;
                // Show padding if system keyboard is showing OR if Hindi keyboard might be showing (Hindi mode + focus)
                final shouldShowKeyboardPadding = isHindiLanguage && hasFocus && viewInsets == 0;
                
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: Dimens.horizontalspacing,
                    right: Dimens.horizontalspacing,
                    // Only add extra padding for Hindi locale, not for English
                    bottom: isHindiLanguage && shouldShowKeyboardPadding
                        ? hindiKeyboardHeight 
                        : (viewInsets > 0 ? viewInsets : 0),
                  ),
                  child: Consumer<UserRegisterViewModel>(
                builder: (context, provider, _) {
                  debugPrint("🟡 [UserRegisterView] Consumer rebuild - aadharImage: ${provider.aadharImage?.path}, voterIdImage: ${provider.voterIdImage?.path}");
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
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                          enableSpeechInput: true,
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
                           useEnglishKeyboard: true,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                          enableSpeechInput: true,
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

                        MapSearchLocation(
                          findPincode: (text) async {
                            try {
                              // Validate pincode before processing
                              final trimmedPincode = text.trim();
                              
                              // Check if pincode is valid (6 digits and numeric)
                              if (trimmedPincode.length == 6) {
                                final pincodeInt = int.tryParse(trimmedPincode);
                                if (pincodeInt != null) {
                                  // Valid numeric pincode - proceed with API call
                              mapsProvider.districtController.text =
                                  await constituencyProvider
                                      .getParliamentaryConstituencies(
                                            pincode: trimmedPincode,
                                        parlimentController:
                                            parliamentaryconstituencyController,
                                      ) ??
                                  "";
                                } else {
                                  // Invalid format - show error
                                  debugPrint("⚠️ Invalid pincode format: $text");
                                }
                              }
                            } catch (e) {
                              debugPrint("❌ Error in findPincode callback: $e");
                              // Error is already handled in getParliamentaryConstituencies
                            }
                          },
                        ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.date_of_birth,
                          hintText: "01-01-2000",
                          controller: provider.dobController,
                          prefixIcon: AppImages.calenderIcon,
                          showDefaultSuffix: false,
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
                        ParliamentaryConstituencyDropDownWidget(
                          constituencyController:
                              parliamentaryconstituencyController,
                          onChange: (constituency) {
                            assemblyconstituencyController.clear();
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
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                          enableSpeechInput: true,
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
                          isRequired: false,
                          headingText: localization.voter_id,
                          hintText: "ABC1234567",
                          maxLength: 10,
                          controller: provider.voterIdController,
                          enableSpeechInput: true,
                          disableHindiKeyboardOverlay:  true,
                          prefixIcon: AppImages.aadharIcon,
                          keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                         
                          onChanged: (value) => provider.generateVoter(value),
                        ),
                        UploadImageWidget(
                          title: localization.upload_voter_id,
                          onTap: () => provider.selectImage(isAadhar: false),
                          onRemoveTap: () =>
                              provider.removeImage(isAadhar: false),
                          imageFile: provider.voterIdImage,
                        ),
                        FormTextFormField(
                          isRequired: false,
                          headingText: localization.invited_by,
                          hintText: localization.invited_by_hint,
                          controller: provider.invitedByController,
                          prefixIcon: AppImages.userIcon,
                          keyboardType: TextInputType.text,
                          disableHindiKeyboardOverlay:  true,
                          textCapitalization: TextCapitalization.sentences,
                          enableSpeechInput: true,
                          enforceFirstLetterUppercase: true,

                        ),
                      ],
                    ),
                  );
                },
              ),
                );
              },
            ),
            bottomNavigationBar:
                Consumer2<UserRegisterViewModel, MapSearchViewModel>(
                  builder: (context, value, searchProvider, _) {
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
                          // Debug: Check controller values
                          final assemblyId = assemblyconstituencyController.value?.sId;
                          final parliamentaryId = parliamentaryconstituencyController.value?.sId;
                          
                          debugPrint('Assembly Constituency ID: $assemblyId');
                          debugPrint('Parliamentary Constituency ID: $parliamentaryId');
                          debugPrint('Assembly Constituency Value: ${assemblyconstituencyController.value}');
                          await provider.registerUserDetails(
                            searchProvider: searchProvider,
                            assemblyConstituenciesID: assemblyId,
                            parliamentaryConstituenciesID: parliamentaryId,
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
