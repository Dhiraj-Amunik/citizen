import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_image_widget.dart';
import 'package:inldsevak/features/common_fields/widget/mla_drop_down.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/viewmodel/appointments_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/viewmodel/request_appointment_view_model.dart';
import 'package:provider/provider.dart';

class RequestAppointmentView extends StatelessWidget with DateAndTimePicker {
  const RequestAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileViewModel>().profile;
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => RequestAppointmentViewModel(),
      builder: (context, child) {
        final provider = context.read<RequestAppointmentViewModel>();
        final style = context.textTheme.bodySmall;
        return Scaffold(
          appBar: commonAppBar(title: localization.request_appointment),
          body: SingleChildScrollView(
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
                          headerBuilder: (_, data, _) {
                            return Text(data?.value ?? "", style: style);
                          },
                          listItemBuilder: (_, data, _, _) {
                            return Text(data?.value ?? "", style: style);
                          },
                          onChanged: (data) {
                            if (data?.key == 'self') {
                              provider.autoFillData(profileProvider);
                            } else {
                              provider.clearAutoFill();
                            }
                          },
                          validator: (text) => text.toString().validateDropDown(
                            argument: "Please select one option",
                          ),
                        ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.name,
                          hintText: localization.enter_your_full_name,
                          controller: provider.nameController,
                          keyboardType: TextInputType.name,
                          validator: (text) => text?.validate(
                            argument: localization.name_validator,
                          ),
                        ),
                        FormTextFormField(
                          maxLength: 10,
                          isRequired: true,
                          headingText: localization.phone_number,
                          hintText: localization.enter_mobile_number,
                          controller: provider.phoneNumberController,
                          keyboardType: TextInputType.number,
                          validator: (text) => text?.validateNumber(
                            argument: localization
                                .please_provide_valid_10_digit_number,
                          ),
                        ),

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
                                  provider.companyDateFormat?.toDdMmYyyy() ??
                                  "";
                            }
                          },
                          validator: (text) => text?.validate(
                            argument: localization
                                .please_select_your_appointment_date,
                          ),
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
                          headingText: localization.purpose_of_appointment,
                          hintText: localization.enter_your_appointment_reason,
                          controller: provider.purposeOfAppointmentController,
                          validator: (text) => text?.validate(
                            argument: "Please select your appointment purpose",
                          ),
                        ),
                        FormTextFormField(
                          isRequired: true,
                          headingText: localization.description,
                          hintText: localization.description_info,
                          controller: provider.descriptionController,
                          maxLines: 5,
                          validator: (text) => text?.validate(
                            argument:
                                "Please enter description for appointment",
                          ),
                        ),
                        Consumer<RequestAppointmentViewModel>(
                          builder: (contextP, value, _) {
                            return UploadImageWidget(
                              onTap: () => value.selectImage(),
                              onRemoveTap: () => value.removeImage(),
                              imageFile: value.image,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
