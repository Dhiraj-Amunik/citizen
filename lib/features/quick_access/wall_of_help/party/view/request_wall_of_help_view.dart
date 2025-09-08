import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_party_view_model.dart';
import 'package:provider/provider.dart';

class RequestWallOfHelpView extends StatelessWidget with DateAndTimePicker {
  const RequestWallOfHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return ChangeNotifierProvider(
      create: (context) => WallOfHelpViewModel(),
      builder: (contextP, _) {
        final provider = contextP.read<WallOfHelpViewModel>();
        return Scaffold(
          appBar: commonAppBar(title: localization.wall_of_help),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.horizontalspacing,
              vertical: Dimens.appBarSpacing,
            ),
            child: Form(
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
                    validator: (text) =>
                        text?.validate(argument: localization.name_validator),
                  ),
                  FormTextFormField(
                    isRequired: true,
                    focus: provider.titleFocus,
                    nextFocus: provider.descriptionFocus,
                    controller: provider.titleController,
                    hintText: localization.enter_your_title,
                    headingText: localization.title,
                  ),
                  FormTextFormField(
                    isRequired: true,
                    maxLines: 5,
                    focus: provider.descriptionFocus,
                    controller: provider.descriptionController,
                    hintText: localization.enter_detail_description,
                    headingText: localization.description,
                  ),

                  FormTextFormField(
                    isRequired: true,
                    controller: provider.dobController,
                    suffixIcon: AppImages.calenderIcon,
                    showCursor: false,
                    onTap: () async {
                      final date = await customDatePicker();
                      if (date != null) {
                        provider.dobController.text = userDateFormat(date);
                        provider.companyDateFormat = companyDateFormat(date);
                      }
                    },
                    headingText: localization.date_of_submission,
                    hintText: localization.select_date,
                    keyboardType: TextInputType.none,
                  ),
                  FormTextFormField(
                    isRequired: true,
                    maxLength: 10,
                    controller: provider.contactController,
                    hintText: localization.enter_contact_number,
                    headingText: localization.contact_number,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: Dimens.horizontalspacing,
              vertical: Dimens.verticalspacing,
            ),
            child: CommonButton(
              text: localization.submit,
              onTap: () => RouteManager.pop(),
            ),
          ),
        );
      },
    );
  }
}
