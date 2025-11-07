import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:provider/provider.dart';

class MapSearchLocation extends StatefulWidget {
  final String? text;
  final Function(bool)? visibility;
  final Function(String) findPincode;
  final bool? showTextFields;
  final AddressModel? addressModel;
  const MapSearchLocation({
    super.key,
    this.text,
    this.visibility,
    this.showTextFields,
    this.addressModel,
    required this.findPincode,
  });

  @override
  State<MapSearchLocation> createState() => _MapSearchLocationState();
}

class _MapSearchLocationState extends State<MapSearchLocation>
    with CupertinoDialogMixin {
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {

    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        context.read<MapSearchViewModel>().clear();
      },
      child: Consumer<MapSearchViewModel>(
        builder: (context, value, _) {
          return Column(
            spacing: Dimens.textFromSpacing,

            children: [
              CommonButton(
                height: Dimens.scaleX5,
                padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                color: AppPalettes.whiteColor,
                textColor: AppPalettes.blackColor,
                borderColor: AppPalettes.blackColor,
                indicatorColor: AppPalettes.primaryColor,
                radius: Dimens.radius100,
                text: "Use my location",
                onTap: () async {
                  await value.getCurrentLocation(widget.findPincode);
                },
                isLoading: !value.isEnabled,
                isEnable: value.isEnabled,
              ).onlyPadding(top: Dimens.gapX1),

              FormTextFormField(
                isRequired: true,
                controller: value.flatNoController,
                headingText: "Flat, House no, Apartment",
                hintText: "House Number",
                validator: (text) =>
                    text?.validate(argument: "Please enter your house number"),
              ),
              FormTextFormField(
                isRequired: true,
                headingText: "Area, Street",
                hintText: "Area",
                controller: value.areaController,
                validator: (text) =>
                    text?.validate(argument: "Please enter your area"),
              ),
              FormCommonChild(
                heading: localization.pincode,
                child: Row(
                  spacing: Dimens.gapX4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FormTextFormField(
                        hintText: localization.pincode_6_digits,
                        controller: value.pincodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (text) =>
                            text?.validatePincode(argument: "Enter Pincode"),
                      ),
                    ),
                    Expanded(
                      child: CommonButton(
                        text: "Find",
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.paddingX2,
                        ),
                        height: Dimens.scaleX5,
                        onTap: () {
                          customRightCupertinoDialog(
                            content: "Do u want to change the pincode?",
                            rightButton: "Search",
                            onTap: () {
                              RouteManager.pop();
                              widget.findPincode(value.pincodeController.text);
                              value.clear(safeClear: false);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                spacing: Dimens.gapX4,
                children: [
                  Expanded(
                    child: FormTextFormField(
                      headingText: "Tehsil",
                      hintText: "Tehsil",
                      controller: value.tehsilController,
                      validator: (text) =>
                          text?.validate(argument: "Enter Tehsil"),
                    ),
                  ),
                  Expanded(
                    child: FormTextFormField(
                      headingText: "City / Town",
                      hintText: localization.city,
                      controller: value.cityController,
                      validator: (text) =>
                          text?.validate(argument: "Enter City"),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: Dimens.gapX4,
                children: [
                  Expanded(
                    child: FormTextFormField(
                      headingText: localization.district,
                      hintText: localization.district,
                      controller: value.districtController,
                      validator: (text) =>
                          text?.validate(argument: "Enter District"),
                    ),
                  ),
                  Expanded(
                    child: FormTextFormField(
                      headingText: localization.state,
                      hintText: localization.state,
                      controller: value.stateController,
                      validator: (text) =>
                          text?.validate(argument: "Enter State"),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
