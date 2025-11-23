import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_request_edit_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart'
    as types;
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart'
    as preferred;

class MyHelpRequestEditView extends StatelessWidget {
  final model.FinancialRequest editableData;
  const MyHelpRequestEditView({super.key, required this.editableData});

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
                      controller: provider.typeOfHelpController,
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

                    // UploadMultiFilesWidget(
                    //   title: localization.supporting_documents,
                    //   onTap: () {
                    //     showModalBottomSheet(
                    //       context: context,
                    //       builder: (context) => DraggableSheetWidget(
                    //         size: 0.5,
                    //         child: selectMultipleFiles(
                    //           onTap: provider.addFiles,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   onRemove: (int index) => provider.removefile(index),
                    //   multipleFiles: provider.multipleFiles,
                    // ),
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
