import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/common_fields/widget/assembly_constituency_drop_down.dart';
import 'package:inldsevak/features/complaints/view_model/add_complaints_view_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart'
    as departments;
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';

import 'package:provider/provider.dart';

class LodgeComplaintView extends StatelessWidget {
  const LodgeComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    final constituencyController = SingleSelectController<Constituency>(null);

    final profile = context.read<ProfileViewModel>();
    final constituencyProvider = context.read<ConstituencyViewModel>();
    final localization = context.localizations;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assemblyId = profile.parlimentaryConstituencyData?.sId;
      if (assemblyId != null && assemblyId.isNotEmpty) {
        constituencyProvider.getAssemblyConstituencies(id: assemblyId).then((_) {
          final match = constituencyProvider.assemblyConstituencyLists.firstWhere(
            (constituency) =>
                constituency?.sId == profile.assemblyConstituencyData?.sId,
            orElse: () => null,
          );
          if (match != null) {
            constituencyController.value = match;
          }
        });
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        constituencyProvider.getAssemblyConstituencies(
          id: profile.parlimentaryConstituencyData?.sId,
        );
      },
      child: ChangeNotifierProvider(
        create: (context) => AddComplaintsViewModel(),
        child: Scaffold(
          appBar: commonAppBar(
            title: localization.submit_new_complaint,
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
                        isRequired: true,
                        controller: value.titleController,
                        headingText: localization.complaint_title,
                        hintText: localization.enter_title,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (value) => value?.validate(
                          argument: localization.please_enter_a_title,
                        ),
                      ),
                      
                      AssemblyConstituencyDropDownWidget(
                        constituencyController: constituencyController,
                      ),
                      FormCommonDropDown<departments.Data>(
                        isRequired: true,
                        // onChanged: (department) {
                        //   value.getAuthorities(id: department?.sId);
                        // },
                        heading: localization.department,
                        hintText: localization.select_department,
                        items: value.departmentLists,
                        controller: value.departmentController,
                        listItemBuilder: (p0, department, p2, p3) {
                          return Text(
                            "${department.name}",
                            style: context.textTheme.bodySmall,
                          );
                        },
                        headerBuilder: (p0, department, p2) {
                          return Text(
                            "${department.name}",
                            style: context.textTheme.bodySmall,
                          );
                        },
                        validator: (value) => value.toString().validateDropDown(
                          argument: "Please select one department",
                        ),
                      ),
                      // FormCommonDropDown<authorities.Data>(
                      //   isRequired: true,
                      //   heading: localization.authority,
                      //   hintText: localization.select_authority,
                      //   items: value.authoritiesLists,
                      //   controller: value.authortiyController,
                      //   listItemBuilder: (p0, authoritie, p2, p3) {
                      //     return Text(
                      //       "${authoritie.name}",
                      //       style: context.textTheme.bodySmall,
                      //     );
                      //   },
                      //   headerBuilder: (p0, authoritie, p2) {
                      //     return Text(
                      //       "${authoritie.name}",
                      //       style: context.textTheme.bodySmall,
                      //     );
                      //   },
                      //   validator: (value) => value.toString().validateDropDown(
                      //     argument: "Please select one authority",
                      //   ),
                      // ),
                      FormTextFormField(
                        isRequired: true,
                        maxLines: 6,
                        controller: value.descriptionController,
                        headingText: localization.description,
                        hintText: localization.provide_detailed_info,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (value) => value?.validate(
                          argument: localization.please_provide_a_detailed_desc,
                        ),
                      ),
                      UploadMultiFilesWidget(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => DraggableSheetWidget(
                              size: 0.5,
                              child: value.selectMultipleImages(),
                            ),
                          );
                        },
                        onRemove: (int index) => value.removeImage(index),
                        multipleFiles: value.multipleFiles,
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
                    text: localization.raise_complaint,
                    onTap: () => value.lodgeComplaints(
                      constituencyID: constituencyController.value?.sId ?? "",
                    ),
                  )
                  .symmetricPadding(horizontal: Dimens.horizontalspacing)
                  .onlyPadding(
                    top: Dimens.textFromSpacing,
                    bottom: Dimens.verticalspacing,
                  );
            },
          ),
        ),
      ),
    );
  }
}
