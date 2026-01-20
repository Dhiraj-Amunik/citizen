import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_request_edit_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart'
    as types;
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart'
    as preferred;

class MyHelpRequestEditView extends StatelessWidget with HandleMultipleFilesSheet {
  MyHelpRequestEditView({super.key, required this.editableData});
  final model.FinancialRequest editableData;

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final listProvider = context.read<WallOfHelpViewModel>();
    return ChangeNotifierProvider(
      create: (context) => MyHelpRequestEditViewModel(
        data: editableData,
        preferredData: listProvider.preferredWaysList,
        typesData: listProvider.typeOfHelpsList,
      ),
      child: Scaffold(
        appBar: commonAppBar(title: localization.wall_of_help),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.appBarSpacing,
          ),
          child: Consumer<MyHelpRequestEditViewModel>(
            builder: (context, provider, _) {
              return Form(
                key: provider.formKey,
                autovalidateMode: AutovalidateMode.always,
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
                      validator: (text) =>
                          text?.validate(argument: localization.name_validator),
                    ),
                    FormTextFormField(
                      isRequired: true,
                      focus: provider.phoneFocus,
                      nextFocus: provider.addressFocus,
                      controller: provider.phoneController,
                      hintText: localization.enter_mobile_number,
                      headingText: localization.mobile_number,
                      maxLength: 10,
                      enableSpeechInput: true,
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
                      validator: (text) => text?.validate(
                        argument: localization.address_validator,
                      ),
                    ),
                    FormCommonDropDown<types.Data?>(
                      isRequired: true,
                      controller: provider.typeOfHelpController,
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
                    if (provider.typeOfHelpController.value?.name == "Others")
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
                      maxLines: 5,
                      controller: provider.descriptionController,
                      hintText: localization.enter_description_of_request,
                      headingText: localization.description,
                      textCapitalization: TextCapitalization.sentences,
                      enforceFirstLetterUppercase: true,
                      enableSpeechInput: true,
                      validator: (text) => text?.validate(
                        argument: localization.please_enter_few_words,
                      ),
                    ),
                    FormCommonDropDown<String?>(
                      isRequired: true,
                      controller: provider.urgencyController,
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
                      controller: provider.preferredWayController,
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

                    if (provider.preferredWayController.value?.name == "Others")
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
                          provider.preferredWayController.value?.name?.split(
                            " ",
                          )[0],
                        ) ==
                        true)
                      Column(
                        spacing: Dimens.textFromSpacing,
                        children: [
                          FormTextFormField(
                            isRequired: true,
                            controller: provider.amountController,
                            hintText: localization.enter_amount,
                            headingText: localization.raise_amount,
                            enableSpeechInput: true,
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
                            disableHindiKeyboardOverlay: true,
                            headingText: "UPI",
                            validator: (text) => text?.validateUPI(
                              argument: "Enter valid UPI ID",
                            ),
                          ),
                        ],
                      ),
                    if (provider.existingDocuments.isNotEmpty)
                      _ExistingDocumentsGrid(
                        documents: provider.existingDocuments,
                        onRemove: provider.removeExistingDocument,
                      ),
                    Consumer<MyHelpRequestEditViewModel>(
                      builder: (contextP, value, _) {
                        return UploadMultiFilesWidget(
                          title: localization.supporting_documents,
                          onTap: () {
                            // 🔥 Use plain bottom sheet for camera (DraggableSheet causes crashes on low-RAM)
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: false,
                              useRootNavigator: false,
                              builder: (bottomSheetContext) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                                ),
                                child: selectMultipleFiles(
                                  onTap: value.addFiles,
                                  context: bottomSheetContext,
                                ),
                              ),
                            );
                          },
                          onRemove: (int index) => value.removeImage(index),
                          multipleFiles: value.multipleFiles,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.verticalspacing,
          ),
          child: Consumer<MyHelpRequestEditViewModel>(
            builder: (context, value, _) {
              return Row(
                spacing: Dimens.gapX3,
                children: [
                  CommonButton(
                    onTap: value.clear,
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
                      text: localization.update,
                      onTap: () => value.updateFinancialHelp(editableData.sId),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExistingDocumentsGrid extends StatelessWidget {
  const _ExistingDocumentsGrid({
    required this.documents,
    required this.onRemove,
  });

  final List<String> documents;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.gapX,
      children: [
        Text(
          "Uploaded Files",
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppPalettes.lightTextColor,
          ),
        ),
        Wrap(
          spacing: Dimens.gapX1,
          runSpacing: Dimens.gapX1,
          children: List.generate(documents.length, (index) {
            final resolvedUrl = _resolveUrl(documents[index]);
            if (resolvedUrl == null) {
              return const SizedBox.shrink();
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.radiusX2),
                  child: CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      color: AppPalettes.liteGreyColor,
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      color: AppPalettes.liteGreyColor,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 20,
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => onRemove(index),
                    child: CircleAvatar(
                      radius: Dimens.scaleX1B,
                      backgroundColor: AppPalettes.whiteColor,
                      child: Icon(
                        Icons.close,
                        size: Dimens.scaleX1B,
                        color: AppPalettes.redColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  String? _resolveUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('/')) return "${URLs.baseURL}$trimmed";
    return "${URLs.baseURL}/$trimmed";
  }
}
