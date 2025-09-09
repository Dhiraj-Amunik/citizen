import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/common_search_dropdown.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_image_widget.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/view_model/search_view_model.dart';
import 'package:inldsevak/features/profile/view_model/avatar_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/profile/widget/profile_avatar.dart';
import 'package:provider/provider.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView>
    with DateAndTimePicker {
  late ProfileViewModel provider;

  get searchController => null;
  @override
  void initState() {
    provider = context.read<ProfileViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadProfile();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => provider.removeProfile(),
      child: Scaffold(
        appBar: commonAppBar(
          title: localization.edit_details,
          center: true,
          elevation: Dimens.elevation,
        ),
        body: SingleChildScrollView(
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
                  ).onlyPadding(top: Dimens.verticalspacing);
                },
              ),

              Form(
                key: provider.userDetailsFormKey,
                autovalidateMode: provider.autoValidateMode,
                child: Column(
                  spacing: Dimens.textFromSpacing,
                  children: [
                    FormTextFormField(
                      controller: provider.nameController,
                      prefixIcon: AppImages.userProfile,
                      labelText: localization.name,
                      nextFocus: provider.emailFocus,
                      keyboardType: TextInputType.name,
                      validator: (text) =>
                          text?.validate(argument: localization.name_validator),
                    ),
                    FormTextFormField(
                      focus: provider.emailFocus,
                      controller: provider.emailController,
                      prefixIcon: AppImages.emailIcon,

                      labelText: localization.email,
                      validator: (text) => text?.validateEmail(
                        argument: localization.email_validator,
                      ),
                    ),
                    FormTextFormField(
                      labelText: localization.mobile_number,
                      prefixIcon: AppImages.phoneIcon,
                      controller: provider.phoneNumberController,
                      keyboardType: TextInputType.none,
                      enabled: false,
                    ),
                    Consumer<SearchViewModel>(
                      builder: (context, value, _) {
                        return Column(
                          children: [
                            CommonSearchDropDown<Predictions>(
                              future: (text) async {
                                final data = await value.getSearchPlaces(text);
                                return data;
                              },
                              isRequired: true,
                              heading: localization.address,
                              hintText: localization.select_address,
                              items: value.searchplaces,
                              initialData: provider.address,
                              controller: searchController,
                              listItemBuilder: (p0, p1, p2, onTap) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        Dimens.paddingX1B,
                                      ),
                                      decoration:
                                          boxDecorationRoundedWithShadow(
                                            Dimens.radius100,
                                            backgroundColor:
                                                AppPalettes.liteGreyColor,
                                          ),
                                      child: Icon(
                                        Icons.location_on_sharp,
                                        color: AppPalettes.lightTextColor,
                                        size: Dimens.scaleX2,
                                      ),
                                    ),
                                    SizeBox.sizeWX3,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p1.structuredFormatting!.mainText
                                                .toString(),
                                            style: textTheme.labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            maxLines: 1,
                                          ),
                                          Text(
                                            p1
                                                    .structuredFormatting!
                                                    .secondaryText ??
                                                "~~~",
                                            style: textTheme.labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: AppPalettes
                                                      .lightTextColor,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Divider(
                                            height: 10,
                                            color: AppPalettes.liteGreyColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                              headerBuilder: (p0, p1, p2) {
                                return Row(
                                  children: [
                                    SvgPicture.asset(AppImages.locationIcon),
                                    SizeBox.sizeWX3,
                                    Flexible(
                                      child: Text(
                                        p1.description.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    FormTextFormField(
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
                      labelText: localization.date_of_birth,
                      keyboardType: TextInputType.none,
                      validator: (text) => text?.validate(
                        argument: localization.date_of_birth_validator,
                      ),
                    ),
                    FormCommonDropDown<String>(
                      prefixIcon: AppImages.genderIcon,
                      initialData: provider.genderController.value,
                      onChanged: (p0) => provider.genderController.value = p0,
                      items: provider.genderList,
                      hintText: localization.select_gender,
                      validator: (text) => text.toString().validateDropDown(
                        argument: localization.gender_validator,
                      ),
                    ),
                    FormTextFormField(
                      maxLength: 12,
                      controller: provider.aadharController,
                      prefixIcon: AppImages.aadharIcon,
                      labelText: localization.aadhaar_no,
                      keyboardType: TextInputType.number,
                      validator: (text) => text?.validate(
                        argument: localization.aadhar_validator,
                      ),
                    ),
                    Consumer<ProfileViewModel>(
                      builder: (context, value, _) {
                        return UploadImageWidget(
                          title: "Upload Aadhard card",
                          onTap: () => value.selectImage(),
                          onRemoveTap: () => value.removeImage(),
                          imageFile: value.image,
                        );
                      },
                    ),
                  ],
                ).symmetricPadding(horizontal: Dimens.horizontalspacing),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.verticalspacing,
          ),
          child: Consumer<ProfileViewModel>(
            builder: (context, value, _) {
              return CommonButton(
                text: localization.update_profile,
                onTap: () => value.updateUserProfile(),
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
