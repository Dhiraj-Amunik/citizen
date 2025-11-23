import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/view_model/create_notify_representative_view_model.dart';
import 'package:inldsevak/features/notify_representative/view_model/notify_representative_view_model.dart';
import 'package:provider/provider.dart';

class CreateNotifyRepresentativeView extends StatelessWidget
    with HandleMultipleFilesSheet, DateAndTimePicker {
  const CreateNotifyRepresentativeView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => CreateNotifyRepresentativeViewModel(),
      builder: (context, _) {
        final provider = context.read<CreateNotifyRepresentativeViewModel>();
        return Scaffold(
          appBar: commonAppBar(title: localization.notify_representative),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
            child: Consumer<CreateNotifyRepresentativeViewModel>(
              builder: (contextP, value, _) {
                return Form(
                  key: provider.formKey,
                  autovalidateMode: value.autoValidateMode,
                  child: Column(
                    spacing: Dimens.textFromSpacing,
                    children: [
                      FormTextFormField(
                        isRequired: true,
                        headingText: localization.event_type,
                        hintText: localization.title,
                        controller: provider.eventTypeController,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        
                        validator: (text) => text?.validate(
                          argument: localization.event_title_validatore,
                        ),
                      ),
                      // Village Field - Text input
                      FormTextFormField(
                        isRequired: true,
                        headingText: 'Village',
                        hintText: 'Enter Village',
                        controller: provider.villageController,
                        textCapitalization: TextCapitalization.words,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: 'Please enter Village',
                        ),
                      ),
                      // FormTextFormField(
                      //   isRequired: true,
                      //   headingText: localization.location_venue,
                      //   hintText: localization.enter_location,
                      //   controller: provider.locationController,
                      //   textCapitalization: TextCapitalization.sentences,
                      //   enforceFirstLetterUppercase: true,
                      //   enableSpeechInput: true,
                      //   validator: (text) => text?.validate(
                      //     argument: localization.event_location_validator,
                      //   ),
                      // ),

                      // District Field - Text input
                      FormTextFormField(
                        isRequired: true,
                        headingText: 'District',
                        hintText: 'Enter District',
                        controller: provider.districtController,
                        textCapitalization: TextCapitalization.words,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: 'Please enter District',
                        ),
                      ),
                      // Mandal Field - Text input
                      FormTextFormField(
                        isRequired: true,
                        headingText: 'Mandal',
                        hintText: 'Enter Mandal',
                        controller: provider.mandalController,
                        textCapitalization: TextCapitalization.words,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: 'Please enter Mandal',
                        ),
                      ),

                      // Street Field
                      FormTextFormField(
                        isRequired: true,
                        headingText: 'Street',
                        hintText: 'Enter Street',
                        controller: provider.streetController,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: 'Please enter Street',
                        ),
                      ),

                      // Pincode Field
                      FormTextFormField(
                        isRequired: true,
                        headingText: 'Pincode',
                        hintText: 'Enter Pincode',
                        controller: provider.pincodeController,
                        keyboardType: TextInputType.number,
                        enableSpeechInput: true,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        maxLength: 6,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Please enter Pincode';
                          }
                          if (text.length != 6) {
                            return 'Please enter valid 6-digit Pincode';
                          }
                          return null;
                        },
                      ),

                      FormTextFormField(
                        isRequired: true,
                        headingText: localization.event_date,
                        keyboardType: TextInputType.none,
                        hintText: localization.dd_mm_yyyy,
                        controller: provider.dateController,
                        suffixIcon: AppImages.calenderIcon,
                        showCursor: false,
                        onTap: () async {
                          final date = await customDatePicker(
                            startDate: DateTime.now(),
                            endDate: DateTime(
                              DateTime.now().year,
                              DateTime.now().month + 2,
                            ),
                          );
                          if (date != null) { 
                            provider.companyDateFormat = date
                                .toString()
                                .toYyyyMmDd();
                            provider.dateController.text =
                                provider.companyDateFormat?.toDdMmYyyy() ?? "";
                          }
                        },
                        validator: (text) => text?.validate(
                          argument: localization.event_date_validatore,
                        ),
                      ),
                      FormTextFormField(
                        isRequired: true,
                        suffixIcon: AppImages.clockIcon,
                        headingText: localization.event_time,
                        hintText: localization.select_time,
                        keyboardType: TextInputType.none,
                        showCursor: false,
                        controller: provider.eventTimeController,
                        onTap: () async {
                          final time = await custom24HrsTimePicker();
                          provider.eventTimeController.text = time ?? "";
                        },
                        validator: (text) => text?.validate(
                          argument: localization.event_time_validatore,
                        ),
                      ),

                      FormTextFormField(
                        isRequired: true,
                        headingText: localization.description,
                        hintText: 'Enter detailed description for notify representative',
                        controller: provider.descriptionController,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: localization.notify_description_validatore,
                        ),
                      ),
                      
                      // MLA Dropdown
                      Consumer<CreateNotifyRepresentativeViewModel>(
                        builder: (contextP, value, _) {
                          if (value.filtersData?.mlas != null &&
                              value.filtersData!.mlas!.isNotEmpty) {
                            return FormCommonDropDown<MlaFilter>(
                              isRequired: true,
                              heading: 'Select MLA',
                              hintText: 'Choose MLA',
                              controller: value.mlaController,
                              items: value.filtersData!.mlas,
                              listItemBuilder: (context, mla, _, __) {
                                return Text(
                                  mla.user?.name ?? '',
                                  style: context.textTheme.bodySmall,
                                );
                              },
                              headerBuilder: (context, mla, _) {
                                return Text(
                                  mla.user?.name ?? '',
                                  style: context.textTheme.bodySmall,
                                );
                              },
                              validator: (MlaFilter? mla) {
                                if (mla == null) {
                                  return localization.mla_validator;
                                }
                                return null;
                              },
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),

                      Consumer<CreateNotifyRepresentativeViewModel>(
                        builder: (contextP, value, _) {
                          return UploadMultiFilesWidget(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => DraggableSheetWidget(
                                  size: 0.5,
                                  child: selectMultipleFiles(
                                    onTap: value.addFiles,
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
          bottomNavigationBar:
              Consumer2<
                CreateNotifyRepresentativeViewModel,
                NotifyRepresentativeViewModel
              >(
                builder: (contextP, value, notify, _) {
                  return CommonButton(
                        isEnable: !value.isLoading,
                        isLoading: value.isLoading,
                        onTap: () => provider.requestNotify(
                          onCompleted: notify.onRecentRefresh,
                        ),
                        text: localization.notify,
                      )
                      .symmetricPadding(horizontal: Dimens.horizontalspacing)
                      .onlyPadding(
                        top: Dimens.textFromSpacing,
                        bottom: Dimens.verticalspacing,
                      );
                },
              ),
        );
      },
    );
  }
}
