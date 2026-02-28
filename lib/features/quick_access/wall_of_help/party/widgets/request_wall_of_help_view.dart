import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart'
    as types;
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart'
    as preferred;

class RequestWallOfHelpView extends StatefulWidget {
  const RequestWallOfHelpView({super.key});

  @override
  State<RequestWallOfHelpView> createState() => _RequestWallOfHelpViewState();
}

class _RequestWallOfHelpViewState extends State<RequestWallOfHelpView>
    with HandleMultipleFilesSheet {
  late final SingleSelectController<types.Data?> typeOfHelpController;
  late final SingleSelectController<String?> urgencyController;
  late final SingleSelectController<preferred.Data?> preferredWayController;

  @override
  void initState() {
    super.initState();
    typeOfHelpController = SingleSelectController<types.Data?>(null);
    urgencyController = SingleSelectController<String?>(null);
    preferredWayController = SingleSelectController<preferred.Data?>(null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clear form data every time the screen is accessed
    // This ensures fresh form when navigating to/back to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _resetForm();
      }
    });
  }

  void _resetForm() {
    if (!mounted) return;

    final provider = context.read<WallOfHelpViewModel>();

    // Clear dropdown controllers
    urgencyController.clear();
    typeOfHelpController.clear();
    preferredWayController.clear();

    // Clear all ViewModel form data (controllers, files, form state)
    provider.clear();

    // Force a rebuild to ensure UI updates immediately
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    typeOfHelpController.dispose();
    urgencyController.dispose();
    preferredWayController.dispose();
    super.dispose();
  }

  void _clearForm() {
    if (mounted) {
      _resetForm();
    }
  }

  Future<void> _handleSubmit(WallOfHelpViewModel provider) async {
    if (!provider.formKey.currentState!.validate()) {
      provider.autoValidateMode = AutovalidateMode.onUserInteraction;
      return;
    }

    final success = await provider.createFinancialHelp(
      urgency: urgencyController.value,
      typeOFHelp: typeOfHelpController.value?.sId,
      preferredWay: preferredWayController.value?.sId,
    );

    // Handle success: clear dropdown controllers and navigate back
    if (mounted && success) {
      // Clear dropdown controllers
      urgencyController.clear();
      typeOfHelpController.clear();
      preferredWayController.clear();
      // Navigate back after successful submission
      RouteManager.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _resetForm();
        }
      },
      child: Builder(
        builder: (context) {
          // Check if Hindi keyboard might be shown (Hindi language)
          final isHindiLanguage =
              Localizations.localeOf(context).languageCode == 'hi';
          // Hindi keyboard height is approximately 300px
          const hindiKeyboardHeight = 300.0;

          return Scaffold(
            appBar: commonAppBar(title: localization.wall_of_help),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: Dimens.horizontalspacing,
                right: Dimens.horizontalspacing,
                top: Dimens.appBarSpacing,
                // Only add extra padding for Hindi locale, not for English
                bottom: isHindiLanguage
                    ? hindiKeyboardHeight +
                          MediaQuery.of(context).viewInsets.bottom +
                          Dimens.appBarSpacing
                    : MediaQuery.of(context).viewInsets.bottom +
                          Dimens.appBarSpacing,
              ),
              child: Consumer<WallOfHelpViewModel>(
                builder: (context, provider, _) {
                  return Form(
                    key: provider.formKey,
                    autovalidateMode: provider.autoValidateMode,
                    child: Column(
                      spacing: Dimens.textFromSpacing,
                      children: [
                        FormTextFormField(
                          isRequired: true,
                          focus: provider.nameFocus,
                          nextFocus: provider.phoneFocus,
                          controller: provider.nameController,
                          hintText: localization.enter_your_full_name,
                          headingText: localization.name,
                          enableSpeechInput: true,
                          textCapitalization: TextCapitalization.sentences,
                          enforceFirstLetterUppercase: true,
                          validator: (text) => text?.validate(
                            argument: localization.name_validator,
                          ),
                        ),

                        FormTextFormField(
                          isRequired: true,
                          focus: provider.phoneFocus,
                          nextFocus: provider.addressFocus,
                          controller: provider.phoneController,
                          hintText: localization.enter_mobile_number,
                          headingText: localization.mobile_number,
                          enableSpeechInput: true,
                          maxLength: 10,
                          textCapitalization: TextCapitalization.sentences,
                          enforceFirstLetterUppercase: true,
                          keyboardType: TextInputType.phone,
                          validator: (text) => text?.validate(
                            argument: localization.phone_validator,
                          ),
                        ),
                        FormTextFormField(
                          isRequired: true,
                          focus: provider.addressFocus,
                          controller: provider.addressController,
                          hintText: localization.enter_your_address,
                          headingText: localization.address,
                          enableSpeechInput: true,
                          textCapitalization: TextCapitalization.sentences,
                          enforceFirstLetterUppercase: true,
                          validator: (text) => text?.validate(
                            argument: localization.address_validator,
                          ),
                        ),
                        FormCommonDropDown<types.Data?>(
                          isRequired: true,
                          controller: typeOfHelpController,
                          items: provider.typeOfHelpsList,
                          heading: localization.type_of_help_needed,
                          hintText: localization.choose_the_options,

                          headerBuilder: (_, text, _) {
                            return TranslatedText(
                              text: text?.name?.capitalize() ?? "",
                              style: textTheme.bodySmall,
                              disableTranslation: false,
                            );
                          },
                          listItemBuilder: (_, text, _, _) {
                            return TranslatedText(
                              text: text?.name?.capitalize() ?? "",
                              style: textTheme.bodySmall,
                              disableTranslation: false,
                            );
                          },
                          validator: (text) => text.toString().validateDropDown(
                            argument: localization.dropdown_validator,
                          ),
                          onChanged: (type) {
                            provider.isLoading = false;
                            provider.otherTypeController.clear();
                          },
                        ),
                        if (typeOfHelpController.value?.name == "Others")
                          FormTextFormField(
                            isRequired: true,
                            controller: provider.otherTypeController,
                            hintText: "Enter your reason",
                            headingText: "Be more specific",
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                            enableSpeechInput: true,
                            validator: (text) => text?.validate(
                              argument: "Others Help need to be specified",
                            ),
                          ),

                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.description,
                          hintText: localization.description_info,
                          controller: provider.descriptionController,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          enforceFirstLetterUppercase: true,
                          enableSpeechInput: true,
                          onMicAvailabilityDenied: (message) {
                            CommonSnackbar(
                              text: message.isEmpty
                                  ? "Voice input is currently unavailable."
                                  : message,
                            ).showSnackbar();
                          },

                          validator: (text) => text?.validate(
                            argument: localization.please_enter_few_words,
                          ),
                        ),
                        FormCommonDropDown<String?>(
                          isRequired: true,
                          controller: urgencyController,
                          items: provider.urgencyList,
                          heading: localization.urgency_level,
                          hintText: localization.choose_the_options,
                          headerBuilder: (_, text, _) {
                            return TranslatedText(
                              text: text ?? "",
                              style: textTheme.bodySmall,
                              disableTranslation: false,
                            );
                          },
                          
                          listItemBuilder: (_, text, _, _) {
                            return TranslatedText(
                              text: text ?? "",
                              style: textTheme.bodySmall,
                              disableTranslation: false,
                            );
                          },
                          validator: (text) => text.toString().validateDropDown(
                            argument: localization.dropdown_validator,
                          ),
                        ),
                        FormCommonDropDown<preferred.Data?>(
                          isRequired: true,
                          controller: preferredWayController,
                          items: provider.preferredWaysList,
                          heading: localization.preferred_way_to_receive_help,
                          hintText: localization.choose_the_options,
                          headerBuilder: (_, text, _) {
                            return TranslatedText(
                              text: text?.name?.capitalize() ?? "",
                              style: textTheme.bodySmall,
                              disableTranslation: false,
                            );
                          },
                          listItemBuilder: (_, text, _, _) {
                            return TranslatedText(
                              text: text?.name?.capitalize() ?? "",
                              style: textTheme.bodySmall,
                              disableTranslation: false,
                            );
                          },
                          validator: (text) => text.toString().validateDropDown(
                            argument: localization.dropdown_validator,
                          ),
                          onChanged: (_) {
                            provider.isLoading = false;
                            provider.amountController.clear();
                            provider.otherPreferredController.clear();
                          },
                        ),

                        if (preferredWayController.value?.name == "Others")
                          FormTextFormField(
                            isRequired: true,
                            controller: provider.otherPreferredController,
                            hintText: "Enter your reason",
                            headingText: "Be more specific",
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                            enableSpeechInput: true,
                            validator: (text) => text?.validate(
                              argument: "Others Help need to be specified",
                            ),
                          ),

                        if (["Financial"].contains(
                              preferredWayController.value?.name?.split(" ")[0],
                            ) ==
                            true)
                          Column(
                            spacing: Dimens.textFromSpacing,
                            children: [
                              FormTextFormField(
                                isRequired: true,
                                controller: provider.amountController,
                                hintText: localization.enter_amount,
                                headingText: '${localization.raise_amount} (₹)',
                                maxLength: 10,
                                enableSpeechInput: true,
                                enforceFirstLetterUppercase: true,
                                validator: (text) => text?.validateAmount(
                                  argument: localization.raise_amount_validator,
                                  argument2: localization.less_amount_validator,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              FormTextFormField(
                                isRequired: true,
                                controller: provider.upiIdController,
                                hintText: "Enter UPI Id",
                                headingText: "U P I",
                                enableSpeechInput: true,
                                enforceFirstLetterUppercase: true,
                                disableHindiKeyboardOverlay: true,
                                validator: (text) => text?.validateUPI(
                                  argument: "Enter valid UPI ID",
                                ),
                              ),
                            ],
                          ),

                        UploadMultiFilesWidget(
                          title: localization.supporting_documents,
                          onTap: () {
                            // 🔥 Use plain bottom sheet for camera (DraggableSheet causes crashes on low-RAM)
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: false,
                              useRootNavigator: false,
                              builder: (bottomSheetContext) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    bottomSheetContext,
                                  ).viewInsets.bottom,
                                ),
                                child: selectMultipleFiles(
                                  onTap: provider.addFiles,
                                  context: bottomSheetContext,
                                ),
                              ),
                            );
                          },
                          onRemove: (int index) => provider.removefile(index),
                          multipleFiles: provider.multipleFiles,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: Dimens.horizontalspacing,
                  vertical: Dimens.verticalspacing,
                ),
                child: Consumer<WallOfHelpViewModel>(
                  builder: (context, value, _) {
                    return Row(
                      spacing: Dimens.gapX3,
                      children: [
                        CommonButton(
                          onTap: _clearForm,
                          color: AppPalettes.whiteColor,
                          borderColor: AppPalettes.primaryColor,
                          textColor: AppPalettes.primaryColor,
                          text: localization.clear,
                          fullWidth: false,
                        ),
                        Expanded(
                          child: CommonButton(
                            isLoading: value.isLoading,
                            isEnable: !value.isLoading,
                            text: localization.submit,
                            onTap: () => _handleSubmit(value),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
