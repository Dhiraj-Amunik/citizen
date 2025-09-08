import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/common_dropDown.dart';
import 'package:inldsevak/core/widgets/common_search_dropdown.dart';
import 'package:inldsevak/features/auth/models/request/validate_otp_request_model.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/auth/utils/auth_appbar.dart';
import 'package:inldsevak/features/auth/view_model/search_view_model.dart';
import 'package:inldsevak/features/auth/view_model/user_register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserRegisterView extends StatefulWidget {
  final OtpRequestModel data;
  const UserRegisterView({super.key, required this.data});

  @override
  State<UserRegisterView> createState() => _UserRegisterViewState();
}

class _UserRegisterViewState extends State<UserRegisterView>
    with DateAndTimePicker {
  //
  SingleSelectController<Predictions?> searchController =
      SingleSelectController<Predictions?>(null);
  //
  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
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
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.horizontalspacing,
              ),
              child: Form(
                key: provider.userDetailsFormKey,
                autovalidateMode: context
                    .watch<UserRegisterViewModel>()
                    .autoValidateMode,
                child: Column(
                  spacing: Dimens.widgetSpacing,
                  children: [
                    CommonTextFormField(
                      focus: provider.nameFocus,
                      nextFocus: provider.emailFocus,
                      prefixIcon: AppImages.userIcon,

                      controller: provider.nameController,
                      hintText: localization.name,
                      keyboardType: TextInputType.name,
                      validator: (text) =>
                          text?.validate(argument: localization.name_validator),
                    ),
                    CommonTextFormField(
                      focus: provider.emailFocus,
                      controller: provider.emailController,
                      prefixIcon: AppImages.emailIcon,

                      hintText: localization.email,
                      validator: (text) => text?.validateEmail(
                        argument: localization.email_validator,
                      ),
                    ),
                    Consumer<SearchViewModel>(
                      builder: (context, value, _) {
                        return CommonSearchDropDown<Predictions?>(
                          onChanged: (place) {
                            value.getLocationByPlaceID(place?.placeId ?? "");
                          },
                          hintStyle: textTheme.bodyMedium,
                          future: (text) async {
                            final data = await value.getSearchPlaces(text);
                            return data;
                          },
                          heading: "Address",
                          items: value.searchplaces,
                          controller: searchController,
                          listItemBuilder: (p0, p1, p2, onTap) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(Dimens.paddingX1B),
                                  decoration: boxDecorationRoundedWithShadow(
                                    Dimens.radius100,
                                    backgroundColor: AppPalettes.liteGreyColor,
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
                                        (p1?.structuredFormatting?.mainText ??
                                                "")
                                            .toString(),
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        p1
                                                ?.structuredFormatting
                                                ?.secondaryText ??
                                            "~~~",
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: AppPalettes.lightTextColor,
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
                                    (p1?.description ?? "").toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    CommonTextFormField(
                      prefixIcon: AppImages.phoneIcon,

                      controller: TextEditingController(
                        text: widget.data.phoneNo,
                      ),
                      keyboardType: TextInputType.none,
                      enabled: false,
                    ),
                    CommonTextFormField(
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
                      hintText: localization.date_of_birth,
                      keyboardType: TextInputType.none,
                      validator: (text) => text?.validate(
                        argument: localization.date_of_birth_validator,
                      ),
                    ),
                    CommonDropDown<String>(
                      prefixIcon: AppImages.genderIcon,
                      controller: provider.genderController,
                      items: provider.genderList,
                      hintText: "Gender",
                      validator: (text) => text.toString().validateDropDown(
                        argument: localization.gender_validator,
                      ),
                    ),
                    CommonTextFormField(
                      maxLength: 12,
                      controller: provider.aadharController,
                      prefixIcon: AppImages.aadharIcon,
                      hintText: localization.aadhar_card_number,
                      keyboardType: TextInputType.number,
                      validator: (text) => text?.validate(
                        argument: localization.aadhar_validator,
                      ),
                    ),
                    //
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
