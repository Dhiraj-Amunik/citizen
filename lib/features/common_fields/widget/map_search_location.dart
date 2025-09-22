import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:provider/provider.dart';

class MapSearchLocation extends StatefulWidget {
  final String? text;
  final String hintText;
  final Function(bool)? visibility;
  final bool? showTextFields;
  final AddressModel? addressModel;
  const MapSearchLocation({
    super.key,
    this.text,
    required this.hintText,
    this.visibility,
    this.showTextFields,
    this.addressModel,
  });

  @override
  State<MapSearchLocation> createState() => _MapSearchLocationState();
}

class _MapSearchLocationState extends State<MapSearchLocation> {
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {

    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
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
                color: AppPalettes.whiteColor,
                textColor: AppPalettes.blackColor,
                borderColor: AppPalettes.blackColor,
                radius: Dimens.radius100,
                text: "Use my location",
                onTap: () {
                  value.getCurrentLocation();
                },
              ),
              FormTextFormField(),
              Column(
                spacing: Dimens.textFromSpacing,
                children: [
                  const SizedBox(),
                  Row(
                    spacing: Dimens.gapX4,
                    children: [
                      Expanded(
                        child: FormTextFormField(
                          headingText: localization.city_village,
                          hintText: localization.city,
                          controller: value.cityController,
                        ),
                      ),
                      Expanded(
                        child: FormTextFormField(
                          headingText: localization.district,
                          hintText: localization.district,
                          controller: value.districtController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: Dimens.gapX4,
                    children: [
                      Expanded(
                        child: FormTextFormField(
                          headingText: localization.state,
                          hintText: localization.state,
                          controller: value.stateController,
                        ),
                      ),
                      Expanded(
                        child: FormTextFormField(
                          headingText: localization.pincode,
                          hintText: localization.pincode_6_digits,
                          controller: value.pincodeController,
                        ),
                      ),
                    ],
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
