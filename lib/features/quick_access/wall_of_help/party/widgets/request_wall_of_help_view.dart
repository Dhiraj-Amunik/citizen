import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart'
    as types;
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart'
    as preferred;

class RequestWallOfHelpView extends StatelessWidget
    with HandleMultipleFilesSheet {
  const RequestWallOfHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final typeOfHelpController = SingleSelectController<types.Data?>(null);
    final urgencyController = SingleSelectController<String?>(null);
    final preferredWayController = SingleSelectController<preferred.Data?>(
      null,
    );
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<WallOfHelpViewModel>().clear();
      },
      child: Scaffold(
        appBar: commonAppBar(title: localization.wall_of_help),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.appBarSpacing,
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
                        return Text(
                          text?.name?.capitalize() ?? "",
                          style: textTheme.bodySmall,
                        );
                      },
                      listItemBuilder: (_, text, _, _) {
                        return Text(
                          text?.name?.capitalize() ?? "",
                          style: textTheme.bodySmall,
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
                        return Text(
                          text?.name?.capitalize() ?? "",
                          style: textTheme.bodySmall,
                        );
                      },
                      listItemBuilder: (_, text, _, _) {
                        return Text(
                          text?.name?.capitalize() ?? "",
                          style: textTheme.bodySmall,
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
                            headingText: localization.raise_amount,
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
                            headingText: "UPI",
                            validator: (text) => text?.validateUPI(
                              argument: "Enter valid UPI ID",
                            ),
                          ),
                        ],
                      ),

                    UploadMultiFilesWidget(
                      title: localization.supporting_documents,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => DraggableSheetWidget(
                            size: 0.5,
                            child: selectMultipleFiles(
                              onTap: provider.addFiles,
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
        bottomNavigationBar: Padding(
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
                    onTap: () {
                      urgencyController.clear();
                      typeOfHelpController.clear();
                      preferredWayController.clear();
                      value.clear();
                    },
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
                      onTap: () => value.createFinancialHelp(
                        urgency: urgencyController.value,
                        typeOFHelp: typeOfHelpController.value?.sId,
                        preferredWay: preferredWayController.value?.sId,
                      ),
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
