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
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/common_fields/widget/assembly_constituency_drop_down.dart';
import 'package:inldsevak/features/complaints/view_model/add_complaints_view_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart'
    as departments;
import 'package:inldsevak/features/complaints/model/response/authorites_model.dart'
    as authorities;
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';

import 'package:provider/provider.dart';

class LodgeComplaintView extends StatefulWidget {
  const LodgeComplaintView({super.key});

  @override
  State<LodgeComplaintView> createState() => _LodgeComplaintViewState();
}

class _LodgeComplaintViewState extends State<LodgeComplaintView> {

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
          // Use where().firstOrNull pattern to avoid type error
          final match = constituencyProvider.assemblyConstituencyLists.where(
            (constituency) =>
                constituency?.sId == profile.assemblyConstituencyData?.sId,
          ).firstOrNull;
          if (match != null) {
            constituencyController.value = match;
          }
        }).catchError((error) {
          debugPrint("Error loading assembly constituencies: $error");
        });
      }
    });

    return ChangeNotifierProvider(
      create: (context) => AddComplaintsViewModel(),
      child: Consumer<AddComplaintsViewModel>(
        builder: (context, viewModel, _) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                // Clear form data when user navigates away
                try {
                  context.read<AddComplaintsViewModel>().clearForm();
                } catch (e) {
                  debugPrint("Error clearing form: $e");
                }
              }
              constituencyProvider.getAssemblyConstituencies(
                id: profile.parlimentaryConstituencyData?.sId,
              );
            },
            child: Builder(
              builder: (context) {
                // Ensure departments are loaded if empty
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && viewModel.departmentLists.isEmpty) {
                    // Wait a bit for onInit to complete, then check again
                    Future.delayed(Duration(milliseconds: 500), () {
                      if (mounted && viewModel.departmentLists.isEmpty) {
                        debugPrint("🔄 Retrying getDepartments from view");
                        viewModel.getDepartments().catchError((error) {
                          debugPrint("Error loading departments from view: $error");
                        });
                      }
                    });
                  }
                });
                return Scaffold(
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
                          padding: EdgeInsets.only(
                            left: Dimens.horizontalspacing,
                            right: Dimens.horizontalspacing,
                            top: Dimens.verticalspacing,
                            bottom: Dimens.verticalspacing,
                          ),
                          // Add extra bottom padding to account for Hindi keyboard (approximately 350px)
                          // This ensures the form can scroll up when keyboard is open
                          // Hindi keyboard is shown as overlay, so we add padding to allow scrolling
                          child: Padding(
                            padding: EdgeInsets.only(
                              // Add space for Hindi keyboard overlay + system keyboard if present
                              // Only add extra padding for Hindi locale, not for English
                              bottom: Localizations.localeOf(context).languageCode == 'hi'
                                  ? 350 + MediaQuery.of(context).viewInsets.bottom
                                  : MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Column(
                              spacing: Dimens.textFromSpacing,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FormTextFormField(
                                  isRequired: true,
                                  headingText: localization.complaint_title,
                                  hintText: localization.enter_title,
                                  controller: value.titleController,
                                  textCapitalization: TextCapitalization.sentences,
                                  enforceFirstLetterUppercase: true,
                                  keyboardType: TextInputType.text,
                                  enableSpeechInput: true,
                                  validator: (text) => text?.validate(
                                    argument: localization.please_enter_a_title,
                                  ),
                                ),
                                
                                AssemblyConstituencyDropDownWidget(
                                  constituencyController: constituencyController,
                                ),
                                FormCommonDropDown<departments.Data>(
                                  isRequired: true,
                                  onChanged: (department) {
                                    value.getAuthorities(id: department?.sId);
                                  },
                                  heading: localization.department,
                                  hintText: localization.select_department,
                                  items: value.departmentLists,
                                  controller: value.departmentController,
                                  listItemBuilder: (p0, department, p2, p3) {
                                    return TranslatedText(
                                      text: department.name ?? "",
                                      style: context.textTheme.bodySmall,
                                      disableTranslation: false,
                                    );
                                  },
                                  headerBuilder: (p0, department, p2) {
                                    return TranslatedText(
                                      text: department.name ?? "",
                                      style: context.textTheme.bodySmall,
                                      disableTranslation: false,
                                    );
                                  },
                                  validator: (value) => value.toString().validateDropDown(
                                    argument: localization.department_validator,
                                  ),
                                ),
                                FormCommonDropDown<authorities.Data>(
                                  isRequired: true,
                                  heading: localization.authority,
                                  hintText: localization.select_authority,
                                  items: value.authoritiesLists,
                                  controller: value.authortiyController,
                                  listItemBuilder: (p0, authoritie, p2, p3) {
                                    return Text(
                                       "${authoritie.name}",
                                      style: context.textTheme.bodySmall,
                                    // Authority names are in English/Hinglish from admin panel
                                    );
                                  },
                                  headerBuilder: (p0, authoritie, p2) {
                                    return Text(
                                       "${authoritie.name}",
                                      style: context.textTheme.bodySmall,
                                       // Authority names are in English/Hinglish from admin panel
                                    );
                                  },
                                  validator: (value) => value.toString().validateDropDown(
                                    argument: "Please select one authority",
                                  ),
                                ),
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
                                    // 🔥 Use plain bottom sheet for camera (DraggableSheet causes crashes on low-RAM)
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: false,
                                      useRootNavigator: true,
                                      builder: (context) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                        child: value.selectMultipleImages(context: context),
                                      ),
                                    );
                                  },
                                  onRemove: (int index) => value.removeImage(index),
                                  multipleFiles: value.multipleFiles,
                                ),
                              ],
                            ),
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
                      ).symmetricPadding(horizontal: Dimens.horizontalspacing)
                      .onlyPadding(
                        top: Dimens.textFromSpacing,
                        bottom: Dimens.verticalspacing,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
