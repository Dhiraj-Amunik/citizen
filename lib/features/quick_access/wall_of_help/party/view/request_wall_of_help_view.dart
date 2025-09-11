import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';

class RequestWallOfHelpView extends StatelessWidget {
  const RequestWallOfHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return Scaffold(
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
                        nextFocus: provider.titleFocus,
                        controller: provider.nameController,
                        hintText: localization.enter_your_full_name,
                        headingText: localization.name,
                        keyboardType: TextInputType.name,
                        validator: (text) => text?.validate(
                          argument: localization.name_validator,
                        ),
                      ),
                      FormTextFormField(
                        isRequired: true,
                        focus: provider.titleFocus,
                        nextFocus: provider.amountFocus,
                        controller: provider.titleController,
                        hintText: localization.enter_your_title,
                        headingText: localization.title,
                        validator: (text) => text?.validate(
                          argument: localization
                              .please_enter_the_cause_for_raising_request,
                        ),
                      ),

                      FormTextFormField(
                        isRequired: true,
                        focus: provider.amountFocus,
                        nextFocus: provider.descriptionFocus,
                        controller: provider.amountController,
                        hintText: localization.enter_amount,
                        headingText: localization.raise_amount,
                        validator: (text) => text?.validate(
                          argument: localization.raise_amount_validator,
                        ),
                      ),

                      FormTextFormField(
                        isRequired: true,
                        maxLines: 5,
                        focus: provider.descriptionFocus,
                        controller: provider.descriptionController,
                        hintText: localization.enter_your_issue,
                        headingText: localization.description,
                        validator: (text) => text?.validate(
                          argument: localization.please_enter_few_words,
                        ),
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
                return CommonButton(
                  isLoading: value.isLoading,
                  isEnable: !value.isLoading,
                  text: localization.submit,
                  onTap: () => value.createFinancialHelp(),
                );
              },
            ),
          ),
        );
  }
}
