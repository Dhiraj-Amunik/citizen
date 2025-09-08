import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_image_widget.dart';
import 'package:inldsevak/features/complaints/model/official.dart';
import 'package:inldsevak/features/complaints/view_model/add_complaints_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/officials_data.dart';
import 'package:inldsevak/features/quick_access/appointments/viewmodel/request_appointment_view_model.dart';
import 'package:provider/provider.dart';

class LodgeComplaintView extends StatelessWidget {
  const LodgeComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return ChangeNotifierProvider(
      create: (context) => AddComplaintsViewModel(),
      child: Scaffold(
        appBar: commonAppBar(
          title: localization.lodge_complaint,
          elevation: Dimens.elevation,
        ),

        body: Consumer<AddComplaintsViewModel>(
          builder: (context, value, _) {
            return Form(
              key: value.formKey,
              autovalidateMode: value.autoValidateMode,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.horizontalspacing,
                  vertical: Dimens.verticalspacing,
                ),
                child: Column(
                  spacing: Dimens.textFromSpacing,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormTextFormField(
                      controller: value.titleController,
                      headingText: localization.complaint_title,
                      hintText: localization.brief_desc_of_the_issue,
                      validator: (value) => value?.validate(
                        argument: localization.please_enter_a_title,
                      ),
                    ),
                    FormCommonDropDown<String>(
                      isRequired: true,
                      onChanged: (p0) {
                        value.update();
                        value.officialController.clear();
                      },
                      heading: "Constituencies",
                      items: value.constituencies,
                      controller: value.constituenciesController,
                    ),

                    FormCommonDropDown<String>(
                      onChanged: (p0) {
                        value.update();
                        value.officialController.clear();
                      },
                      heading: localization.department,
                      items: OfficialsData.getAllDepartments(),
                      controller: value.departmentController,
                    ),

                    Column(
                      children: [
                        FormCommonDropDown<Official>(
                          onChanged: (p0) => value.update(),
                          heading: localization.official,
                          items: OfficialsData.getOfficialsByDepartment(
                            value.departmentController.value ?? "",
                          ),
                          controller: value.officialController,
                          headerBuilder: (p0, p1, p2) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(p1.name, style: textTheme.bodySmall),
                                Text(
                                  " (${p1.designation})",
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppPalettes.lightTextColor,
                                  ),
                                ),
                              ],
                            );
                          },
                          listItemBuilder: (p0, p1, p2, _) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(p1.name, style: textTheme.bodySmall),
                                Text(
                                  " (${p1.designation})",
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppPalettes.lightTextColor,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (value.officialController.value != null)
                          Container(
                            margin: EdgeInsets.only(top: Dimens.marginX2),
                            padding: EdgeInsets.all(Dimens.paddingX3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.blue,
                                  size: Dimens.scaleX2,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    value.officialController.value!.email,
                                    style: textTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    FormTextFormField(
                      maxLines: 6,
                      controller: value.descriptionController,
                      headingText: localization.detailed_desc,
                      hintText: localization.provide_detailed_info,
                      validator: (value) => value?.validate(
                        argument: localization.please_provide_a_detailed_desc,
                      ),
                    ),
                    UploadImageWidget(
                      onTap: () => value.selectImage(),
                      onRemoveTap: () => value.removeImage(),
                      imageFile: value.image,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Consumer<AddComplaintsViewModel>(
          builder: (context, value, _) {
            return CommonButton(
                  isEnable: !value.isLoading,
                  isLoading: value.isLoading,
                  text: localization.submit_complaint,
                  onTap: () => value.lodgeComplaints(),
                )
                .symmetricPadding(horizontal: Dimens.horizontalspacing)
                .onlyPadding(
                  top: Dimens.textFromSpacing,
                  bottom: Dimens.verticalspacing,
                );
          },
        ),
      ),
    );
  }
}
