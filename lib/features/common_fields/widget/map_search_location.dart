import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:provider/provider.dart';

class MapSearchLocation extends StatefulWidget {
  final String? text;
  final Function(bool)? visibility;
  final Function(String) findPincode;
  final bool? showTextFields;
  final bool? hideHouseNumber;
  final bool? hideUseMyLocation;
  final bool? hideFindButton;
  final bool? areaAndPincodeInRow;
  final AddressModel? addressModel;
  const MapSearchLocation({
    super.key,
    this.text,
    this.visibility,
    this.showTextFields,
    this.hideHouseNumber,
    this.hideUseMyLocation,
    this.hideFindButton,
    this.areaAndPincodeInRow,
    this.addressModel,
    required this.findPincode,
  });

  @override
  State<MapSearchLocation> createState() => _MapSearchLocationState();
}

class _MapSearchLocationState extends State<MapSearchLocation>
    with CupertinoDialogMixin {
  StreamSubscription<dynamic>? _languageSubscription;
  String? _lastTranslatedDistrict;
  bool _isTranslatingDistrict = false;
  TextEditingController? _districtController;

  @override
  void initState() {
    super.initState();
    // Listen to language changes to translate district controller text
    _languageSubscription = GeneralStream.instance.language.listen((_) {
      if (mounted) {
        _translateDistrictController();
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    _districtController?.removeListener(_onDistrictTextChanged);
    super.dispose();
  }

  void _onDistrictTextChanged() {
    if (!mounted || _isTranslatingDistrict) return;
    // Translate when district text changes (e.g., when loaded from API)
    _translateDistrictController();
  }

  Future<void> _translateDistrictController() async {
    if (!mounted || _isTranslatingDistrict) return;

    final mapSearchViewModel = context.read<MapSearchViewModel>();
    final districtText = mapSearchViewModel.districtController.text;

    if (districtText.isEmpty) {
      _lastTranslatedDistrict = null;
      return;
    }

    // Skip if this is the same text we already translated
    if (districtText == _lastTranslatedDistrict) return;

    // Check if translation is needed
    final needsTranslation = TranslationHelper.needsTranslation(districtText);
    if (!needsTranslation) {
      _lastTranslatedDistrict = districtText;
      return;
    }

    _isTranslatingDistrict = true;
    try {
      final translated = await TranslationHelper.translateText(districtText);
      if (mounted &&
          mapSearchViewModel.districtController.text == districtText) {
        // Only update if the text hasn't changed (user hasn't edited it)
        mapSearchViewModel.districtController.text = translated;
        _lastTranslatedDistrict = translated;
      }
    } catch (e) {
      // If translation fails, keep original text
      debugPrint('Error translating district: $e');
      _lastTranslatedDistrict = districtText;
    } finally {
      _isTranslatingDistrict = false;
    }
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
          // Set up listener for district controller to translate when text is set
          if (_districtController != value.districtController) {
            _districtController?.removeListener(_onDistrictTextChanged);
            _districtController = value.districtController;
            _districtController?.addListener(_onDistrictTextChanged);
          }

          return Column(
            spacing: Dimens.textFromSpacing,

            children: [
              if (widget.hideUseMyLocation != true)
                CommonButton(
                  height: Dimens.scaleX5,
                  padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                  color: AppPalettes.whiteColor,
                  textColor: AppPalettes.blackColor,
                  borderColor: AppPalettes.blackColor,
                  indicatorColor: AppPalettes.primaryColor,
                  radius: Dimens.radius100,
                  text: localization.use_my_location,
                  onTap: () async {
                    await value.getCurrentLocation(widget.findPincode);
                  },
                  isLoading: !value.isEnabled,
                  isEnable: value.isEnabled,
                ).onlyPadding(top: Dimens.gapX1),

              if (widget.hideHouseNumber != true)
                FormTextFormField(
                  isRequired: true,
                  controller: value.flatNoController,
                  headingText: localization.flat_house_no_apartment,
                  hintText: localization.house_number,
                  textCapitalization: TextCapitalization.sentences,
                  enforceFirstLetterUppercase: true,
                  enableSpeechInput: true,
                  validator: (text) => text?.validate(
                    argument: localization.house_number_validator,
                  ),
                  autovalidateMode: value.addressAutovalidateMode,
                ),
              // Area and Pincode in a single row if areaAndPincodeInRow is true
              widget.areaAndPincodeInRow == true
                  ? Row(
                      spacing: Dimens.gapX4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FormTextFormField(
                            isRequired: true,
                            headingText: localization.area_street,
                            hintText: localization.area,
                            controller: value.areaController,
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                            enableSpeechInput: true,
                            maxLength: 30,
                            validator: (text) => text?.validate(
                              argument: localization.area_validator,
                            ),
                            autovalidateMode: value.addressAutovalidateMode,
                          ),
                        ),
                        Expanded(
                          child: FormCommonChild(
                            heading: localization.pincode,
                            isRequired: true,
                            child: FormTextFormField(
                              hintText: localization.pincode_6_digits,
                              controller: value.pincodeController,
                              enableSpeechInput: true,
                              textCapitalization: TextCapitalization.sentences,
                              enforceFirstLetterUppercase: true,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              onChanged: (text) {
                                if (text != null && text.trim().length == 6) {
                                  widget.findPincode(text.trim());
                                  value.clear(safeClear: false);
                                }
                              },
                              validator: (text) => text?.validatePincode(
                                argument: localization.enter_pincode,
                              ),
                              autovalidateMode: value.addressAutovalidateMode,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      spacing: Dimens.textFromSpacing,
                      children: [
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.area_street,
                          hintText: localization.area,
                          controller: value.areaController,
                          textCapitalization: TextCapitalization.sentences,
                          enforceFirstLetterUppercase: true,
                          enableSpeechInput: true,
                          maxLength: 30,
                          validator: (text) => text?.validate(
                            argument: localization.area_validator,
                          ),
                          autovalidateMode: value.addressAutovalidateMode,
                        ),
                        FormCommonChild(
                          heading: localization.pincode,
                          isRequired: true,
                          child: widget.hideFindButton == true
                              ? FormTextFormField(
                                  hintText: localization.pincode_6_digits,
                                  controller: value.pincodeController,
                                  enableSpeechInput: true,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  enforceFirstLetterUppercase: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  onChanged: (text) {
                                    if (text != null &&
                                        text.trim().length == 6) {
                                      widget.findPincode(text.trim());
                                      value.clear(safeClear: false);
                                    }
                                  },
                                  validator: (text) => text?.validatePincode(
                                    argument: "Enter Pincode",
                                  ),
                                  autovalidateMode:
                                      value.addressAutovalidateMode,
                                )
                              : Row(
                                  spacing: Dimens.gapX4,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: FormTextFormField(
                                        hintText: localization.pincode_6_digits,
                                        controller: value.pincodeController,
                                        enableSpeechInput: true,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        enforceFirstLetterUppercase: true,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        onChanged: (text) {
                                          if (text != null &&
                                              text.trim().length == 6) {
                                            widget.findPincode(text.trim());
                                            value.clear(safeClear: false);
                                          }
                                        },
                                        validator: (text) =>
                                            text?.validatePincode(
                                              argument: "Enter Pincode",
                                            ),
                                        autovalidateMode:
                                            value.addressAutovalidateMode,
                                      ),
                                    ),
                                    Expanded(
                                      child: CommonButton(
                                        text: localization.find,
                                        padding: EdgeInsets.symmetric(
                                          vertical: Dimens.paddingX2,
                                        ),
                                        height: Dimens.scaleX5,
                                        onTap: () {
                                          customRightCupertinoDialog(
                                            content: localization
                                                .do_you_want_to_change_pincode,
                                            rightButton: localization.search,
                                            onTap: () {
                                              RouteManager.pop();
                                              widget.findPincode(
                                                value.pincodeController.text,
                                              );
                                              value.clear(safeClear: false);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
              Row(
                spacing: Dimens.gapX4,
                children: [
                  Expanded(
                    child: FormTextFormField(
                      isRequired: true,
                      headingText: localization.tehsil,
                      hintText: localization.tehsil,
                      controller: value.tehsilController,
                      textCapitalization: TextCapitalization.sentences,
                      enforceFirstLetterUppercase: true,
                      enableSpeechInput: true,
                      maxLength: 30,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                      validator: (text) => text?.validate(
                        argument: localization.tehsil_validator,
                      ),
                      autovalidateMode: value.addressAutovalidateMode,
                    ),
                  ),
                  Expanded(
                    child: FormTextFormField(
                      isRequired: true,
                      headingText: localization.city_town,
                      hintText: localization.city,
                      controller: value.cityController,
                      textCapitalization: TextCapitalization.sentences,
                      enforceFirstLetterUppercase: true,
                      enableSpeechInput: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                      validator: (text) =>
                          text?.validate(argument: localization.city_validator),
                      autovalidateMode: value.addressAutovalidateMode,
                    ),
                  ),
                ],
              ),
              Row(
                spacing: Dimens.gapX4,
                children: [
                  Expanded(
                    child: FormTextFormField(
                      isRequired: true,
                      headingText: localization.district,
                      hintText: localization.district,
                      controller: value.districtController,
                      textCapitalization: TextCapitalization.sentences,
                      enforceFirstLetterUppercase: true,
                      enableSpeechInput: true,
                      maxLength: 30,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                      validator: (text) => text?.validate(
                        argument: localization.district_validator,
                      ),
                      autovalidateMode: value.addressAutovalidateMode,
                    ),
                  ),
                  Expanded(
                    child: FormTextFormField(
                      isRequired: true,
                      headingText: localization.state,
                      hintText: localization.state,
                      controller: value.stateController,
                      textCapitalization: TextCapitalization.sentences,
                      enforceFirstLetterUppercase: true,
                      enableSpeechInput: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                      validator: (text) => text?.validate(
                        argument: localization.state_validator,
                      ),
                      autovalidateMode: value.addressAutovalidateMode,
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
