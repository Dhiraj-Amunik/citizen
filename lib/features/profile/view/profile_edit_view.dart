import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
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
import 'package:inldsevak/core/widgets/upload_image_widget.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/common_fields/widget/assembly_constituency_drop_down.dart';
import 'package:inldsevak/features/common_fields/widget/map_search_location.dart';
import 'package:inldsevak/features/common_fields/widget/parliamentary_constituency_drop_down.dart';
import 'package:inldsevak/features/profile/view_model/avatar_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/profile/widget/profile_avatar.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView>
    with DateAndTimePicker {
  final genderController = SingleSelectController<String?>(null);
  final assemblyconstituencyController = SingleSelectController<Constituency>(
    null,
  );
  final parliamentaryconstituencyController =
      SingleSelectController<Constituency>(null);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    genderController.dispose();
    assemblyconstituencyController.dispose();
    parliamentaryconstituencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final provider = context.read<ProfileViewModel>();
    final constituencyProvider = context.read<ConstituencyViewModel>();
    final mapsProvider = context.read<MapSearchViewModel>();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (constituencyProvider.assemblyConstituencyLists.isEmpty) {
          if (provider.parlimentaryConstituencyData?.sId?.isNotEmpty == true) {
            constituencyProvider.getAssemblyConstituencies(
              id: provider.parlimentaryConstituencyData?.sId,
            );
          }
        }
      },
      child: Scaffold(
        appBar: commonAppBar(title: localization.edit_details),
        body: FutureBuilder(
          future: provider.loadProfile(mapsProvider).then((_) async {
            final parliamentId = provider.parlimentaryConstituencyData?.sId;
            if (parliamentId != null && parliamentId.isNotEmpty) {
              await constituencyProvider.getAssemblyConstituencies(
                id: parliamentId,
              );
              final match = constituencyProvider.assemblyConstituencyLists
                  .firstWhere(
                (constituency) =>
                    constituency?.sId == provider.assemblyConstituencyData?.sId,
                orElse: () => null,
              );
              if (match != null) {
                assemblyconstituencyController.value = match;
              }
            }
          }),
          builder: (_, snapshot) {
            genderController.value = provider.gender;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomAnimatedLoading());
            }

            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                spacing: Dimens.widgetSpacing,
                children: [
                  Consumer2<AvatarViewModel, ProfileViewModel>(
                    builder: (context, value, value2, _) {
                      return ProfileAvatar(
                        image: value2.profile?.avatar,
                        onTap: () => value.selectImage(),
                        onDelete: () => value.removeImage(),
                        file: value.userAvatar,
                      );
                    },
                  ),
                  Form(
                    key: provider.userDetailsFormKey,
                    autovalidateMode: provider.autoValidateMode,
                    child: Column(
                      spacing: Dimens.textFromSpacing,
                      children: [
                        FormTextFormField(
                          isRequired: true,
                          controller: provider.nameController,
                          prefixIcon: AppImages.userProfile,
                          headingText: localization.name,
                          nextFocus: provider.emailFocus,
                          keyboardType: TextInputType.name,
                          enableSpeechInput: true,
                          validator: (text) => text?.validateName(
                            argument: localization.name_validator,
                          ),
                        ),
                        FormTextFormField(
                          isRequired: true,
                          focus: provider.emailFocus,
                          controller: provider.emailController,
                          prefixIcon: AppImages.emailIcon,
                          headingText: localization.email,
                          enableSpeechInput: true,
                          validator: (text) => text?.validateEmail(
                            argument: localization.email_validator,
                          ),
                        ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.mobile_number,
                          prefixIcon: AppImages.phoneIcon,
                          controller: provider.phoneNumberController,
                         showDefaultSuffix: false,
                          keyboardType: TextInputType.none,
                          maxLength: 10,
                          enabled: false,
                        ),

                        MapSearchLocation(
                          findPincode: (text) async {
                            if (text.length == 6) {
                              mapsProvider.districtController.text =
                                  await constituencyProvider
                                      .getParliamentaryConstituencies(
                                        pincode: text,
                                        parlimentController:
                                            parliamentaryconstituencyController,
                                      ) ??
                                  "";
                            }
                          },
                        ),

                        ParliamentaryConstituencyDropDownWidget(
                          initialData: provider.parlimentaryConstituencyData,
                          constituencyController:
                              parliamentaryconstituencyController,
                          onChange: (constituency) {
                            if (constituency == null) return;
                            assemblyconstituencyController.clear();
                            if (constituency.sId.toString().trim() !=
                                    provider.parlimentaryConstituencyData?.sId
                                        .toString()
                                        .trim() ||
                                constituencyProvider
                                    .assemblyConstituencyLists
                                    .isEmpty) {
                              context
                                  .read<ConstituencyViewModel>()
                                  .getAssemblyConstituencies(
                                    id: constituency.sId,
                                  );
                            }
                          },
                        ),
                        AssemblyConstituencyDropDownWidget(
                          initialData: provider.assemblyConstituencyData,
                          constituencyController:
                              assemblyconstituencyController,
                        ),
                        FormTextFormField(
                          isRequired: true,
                          controller: provider.dobController,
                          prefixIcon: AppImages.calenderIcon,
                          showCursor: false,
                          showDefaultSuffix: false,
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
                          headingText: localization.date_of_birth,
                          keyboardType: TextInputType.none,
                          validator: (text) => text?.validate(
                            argument: localization.date_of_birth_validator,
                          ),
                        ),
                        FormCommonDropDown<String?>(
                          isRequired: true,
                          heading: localization.gender,
                          prefixIcon: AppImages.genderIcon,
                          controller: genderController,
                          items: provider.genderList,
                          hintText: localization.select_gender,
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
                          enableSpeechInput: true,
                          validator: (text) => text?.validateAadhar(
                            argument: localization.aadhar_validator,
                          ),
                          onChanged: (value) => provider.generateAadhar(value),
                        ),
                        Consumer<ProfileViewModel>(
                          builder: (_, _, _) {
                            return UploadImageWidget(
                              title: localization.upload_aadhar,
                              onTap: () => provider.selectImage(isAadhar: true),
                              onRemoveTap: () =>
                                  provider.removeImage(isAadhar: true),
                              imageFile: provider.aadharImage,
                              url: provider.aadharURL,
                            );
                          },
                        ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.voter_id,
                          hintText: "ABC1234567",
                          maxLength: 10,
                          controller: provider.voterIdController,
                          prefixIcon: AppImages.aadharIcon,
                          keyboardType: TextInputType.text,
                          enableSpeechInput: true,
                          validator: (text) => text?.validateVoterID(
                            argument: localization.voter_id_validator,
                          ),
                          onChanged: (value) => provider.generateVoter(value),
                        ),
                        Consumer<ProfileViewModel>(
                          builder: (_, _, _) {
                            return UploadImageWidget(
                              title: localization.upload_voter_id,
                              onTap: () =>
                                  provider.selectImage(isAadhar: false),
                              onRemoveTap: () =>
                                  provider.removeImage(isAadhar: false),
                              imageFile: provider.voterIdImage,
                              url: provider.voterIdURL,
                            );
                          },
                        ),
                      ],
                    ).symmetricPadding(horizontal: Dimens.horizontalspacing),
                  ),
                ],
              ),
            );
          },
        ),

        bottomNavigationBar: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.verticalspacing,
          ),
          child:
              Consumer4<
                ProfileViewModel,
                AvatarViewModel,
                MapSearchViewModel,
                ConstituencyViewModel
              >(
                builder: (context, value, avatar, search, constituency, _) {
                  return CommonButton(
                    text: localization.update_profile,
                    onTap: () => value.updateUserProfile(
                      avatar: avatar,
                      genderValue: genderController.value,
                      mapModel: search,
                      assemblyConstituenciesID:
                          assemblyconstituencyController.value?.sId,
                      parliamentaryConstituenciesID:
                          parliamentaryconstituencyController.value?.sId,
                    ),
                    isLoading: value.isLoading,
                    isEnable: !value.isLoading,
                  );
                },
              ),
        ),
      ),
    );
  }
}
