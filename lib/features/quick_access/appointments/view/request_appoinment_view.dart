import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/common_fields/widget/mla_drop_down.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/viewmodel/appointments_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/viewmodel/request_appointment_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:provider/provider.dart';

class RequestAppointmentView extends StatelessWidget with DateAndTimePicker {
  const RequestAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileViewModel>().profile;
    final roleProvider = context.read<RoleViewModel>();
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => RequestAppointmentViewModel(),
      builder: (context, child) {
        final provider = context.read<RequestAppointmentViewModel>();
        final textTheme = context.textTheme;
        // Check if Hindi keyboard might be shown (Hindi language)
        final isHindiLanguage = GeneralStream.instance.locale.languageCode == 'hi';
        // Hindi keyboard height is approximately 300px
        const hindiKeyboardHeight = 300.0;
        
        return Scaffold(
          appBar: commonAppBar(title: localization.request_appointment),
          body: Builder(
            builder: (context) {
              // Check if any text field has focus (which would show Hindi keyboard)
              final hasFocus = FocusScope.of(context).hasFocus;
              final viewInsets = MediaQuery.of(context).viewInsets.bottom;
              // Show padding if system keyboard is showing OR if Hindi keyboard might be showing (Hindi mode + focus)
              final shouldShowKeyboardPadding = isHindiLanguage && hasFocus && viewInsets == 0;
              
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  // Only add extra padding for Hindi locale, not for English
                  bottom: isHindiLanguage && shouldShowKeyboardPadding
                      ? hindiKeyboardHeight 
                      : (viewInsets > 0 ? viewInsets : 0),
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: Dimens.horizontalspacing,
                    vertical: Dimens.paddingX2,
                  ),
                  child: Consumer(
                    builder: (_, _, _) {
                      return Form(
                        key: provider.formKey,
                        autovalidateMode: provider.autoValidateMode,
                        child: Column(
                          spacing: Dimens.textFromSpacing,
                          children: [
                        MlaDropDownWidget(
                          mlaController: provider.mlaController,
                        ),
                        FormCommonDropDown<BookFor?>(
                          isRequired: true,
                          heading: localization.book_for,
                          controller: provider.bookForController,
                          items: provider.bookForList,
                          headerBuilder: (context, data, _) {
                            final text = data?.key == 'self' 
                                ? localization.my_self 
                                : localization.others;
                            return Text(
                              text,
                              style: textTheme.bodySmall,
                            );
                          },
                          listItemBuilder: (context, data, _, _) {
                            final text = data?.key == 'self' 
                                ? localization.my_self 
                                : localization.others;
                            return Text(
                              text,
                              style: textTheme.bodySmall,
                            );
                          },
                          onChanged: (data) {
                            if (data?.key == 'self') {
                              provider.autoFillData(profileProvider);
                            } else {
                              provider.clearAutoFill();
                            }
                          },
                          validator: (text) => text.toString().validateDropDown(
                            argument: localization.dropdown_validator,
                          ),
                        ),
                        FormTextFormField(
                          isRequired: true,
                            enableSpeechInput: true,
                            textCapitalization: TextCapitalization.sentences,
                            enforceFirstLetterUppercase: true,
                          headingText: localization.name,
                          minChar: 5,
                          hintText: localization.enter_your_full_name,
                          controller: provider.nameController,
                          keyboardType: TextInputType.name,
                          validator: (text) => text?.validate(
                            argument: localization.name_validator,
                          ),
                        ),
                        if (roleProvider.isPartyMember)
                          FormTextFormField( 
                             enableSpeechInput: true,
                             textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                            isRequired: true,
                            headingText: localization.membership_id,
                            hintText: localization.membership_id,
                            controller: provider.membershipController,
                            keyboardType: TextInputType.name,
                            validator: (text) => text?.validate(
                              argument: localization.membership_validator,
                            ),
                          ),
                        FormTextFormField(
                          maxLength: 10,
                          isRequired: true,
                            enableSpeechInput: true,
                          headingText: localization.phone_number,
                          hintText: localization.enter_mobile_number,
                          controller: provider.phoneNumberController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          enforceFirstLetterUppercase: true,
                          validator: (text) => text?.validateNumber(
                            argument: localization
                                .please_provide_valid_10_digit_number,
                          ),
                        ),
                        Column(
                          children: [
                            FormTextFormField(
                              isRequired: true,
                              headingText: localization.preferred_date,
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
                                      provider.companyDateFormat
                                          ?.toDdMmYyyy() ??
                                      "";
                                }
                              },
                              validator: (text) => text?.validate(
                                argument: localization
                                    .please_select_your_appointment_date,
                              ),
                            ),
                            SizeBox.sizeHX2,
                            Text(
                              localization.appointment_note,
                              style: textTheme.labelSmall?.copyWith(
                                color: AppPalettes.redColor,
                              ),
                              textAlign: TextAlign.justify,
                            ).horizontalPadding(Dimens.paddingX2),
                            SizeBox.sizeHX1B,
                            FormTextFormField(
                              isRequired: true,
                              headingText: localization.purpose_of_appointment,
                              hintText:
                                  localization.enter_your_appointment_reason,
                              controller:
                                  provider.purposeOfAppointmentController,
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
                                argument:
                                    localization.appointment_purpose_validator,
                              ),
                            ),
                          ],
                        ),
                        // FormCommonDropDown<String>(
                        //   isRequired: true,
                        //   heading: localization.time_slot,
                        //   hintText: localization.select_time_slot,
                        //   controller: provider.timeSlotController,
                        //   items: provider.timeSlotLists,
                        //   validator: (text) => text.toString().validateDropDown(
                        //     argument:
                        //         "Please select time slot for your appointment",
                        //   ),
                        // ),
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
                            argument:
                                localization.appointment_description_validator,
                          ),
                        ),

                        Consumer<RequestAppointmentViewModel>(
                          builder: (contextP, value, _) {
                            return UploadMultiFilesWidget(
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
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
                ),
              );
            },
          ),
          bottomNavigationBar:
              Consumer2<RequestAppointmentViewModel, AppointmentsViewModel>(
                builder: (contextP, value, appointment, _) {
                  return Row(
                        spacing: Dimens.gapX3,
                        children: [
                          CommonButton(
                            onTap: () => provider.clear(),
                            color: AppPalettes.whiteColor,
                            borderColor: AppPalettes.primaryColor,
                            textColor: AppPalettes.primaryColor,
                            text: localization.clear,
                            fullWidth: false,
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.paddingX8,
                              vertical: Dimens.paddingX3,
                            ),
                          ),
                          Expanded(
                            child: CommonButton(
                              isEnable: !value.isLoading,
                              isLoading: value.isLoading,
                              text: localization.submit_application,
                              onTap: () => value.requestNewAppointments(
                                onCompleted: appointment.getAppointmentsList,
                              ),
                            ),
                          ),
                        ],
                      )
                      .symmetricPadding(horizontal: Dimens.horizontalspacing)
                      .onlyPadding(
                        top: Dimens.paddingX2,
                        bottom: Dimens.verticalspacing,
                      );
                },
              ),
        );
      },
    );
  }
}
