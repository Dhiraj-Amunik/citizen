import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_search_dropdown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:provider/provider.dart';

class MapSearchField extends StatefulWidget {
  final String? text;
  final String hintText;
  // final SingleSelectController<Predictions?> searchController;
  final Function(bool)? visibility;
  final bool? showTextFields;
  final AddressModel? addressModel;
  const MapSearchField({
    super.key,
    // required this.searchController,
    this.text,
    required this.hintText,
    this.visibility,
    this.showTextFields,
    this.addressModel,
  });

  @override
  State<MapSearchField> createState() => _MapSearchFieldState();
}

class _MapSearchFieldState extends State<MapSearchField> {
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (widget.addressModel != null) {
    //     widget.searchController.value = Predictions(
    //       description: widget.addressModel?.formattedAddress,
    //     );
    //     context.read<MapSearchViewModel>().loadAddress(
    //       model: widget.addressModel,
    //     );
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        // widget.searchController.clear();
        context.read<MapSearchViewModel>().clear();
      },
      child: Consumer<MapSearchViewModel>(
        builder: (context, value, _) {
          return Column(
            children: [
              Column(
                spacing: Dimens.textFromSpacing,
                children: [
                  const SizedBox(),
                  Row(
                    spacing: Dimens.gapX4,
                    children: [
                      Expanded(
                        child: FormTextFormField(
                          enabled: false,
                          headingText: localization.city_village,
                          hintText: localization.city,
                          controller: value.cityController,
                        ),
                      ),
                      Expanded(
                        child: FormTextFormField(
                          enabled: false,
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
                          enabled: false,
                          headingText: localization.state,
                          hintText: localization.state,
                          controller: value.stateController,
                        ),
                      ),
                      Expanded(
                        child: FormTextFormField(
                          enabled: false,
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


/*

   CommonSearchDropDown<Predictions?>(
                visibility: widget.visibility,
                onChanged: (place) {
                  if (widget.searchController.value?.placeId != null) {
                    value.getLocationByPlaceID(place?.placeId ?? "");
                  }
                },
                future: (text) async {
                  final data = await value.getSearchPlaces(text);
                  return data;
                },
                isRequired: true,
                heading: widget.text,
                hintText: widget.hintText,
                items: value.searchplaces,
                controller: widget.searchController,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (p1?.structuredFormatting?.mainText ?? "")
                                  .toString(),
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              p1?.structuredFormatting?.secondaryText ?? "~~~",
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
              ),
          */