import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_image_widget.dart';
import 'package:inldsevak/features/quick_access/appointments/viewmodel/request_appointment_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart'
    as mla;

class RequestAppointmentView extends StatelessWidget with DateAndTimePicker {
  const RequestAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return ChangeNotifierProvider(
      create: (context) => RequestAppointmentViewModel(),
      builder: (context, child) {
        final provider = context.read<RequestAppointmentViewModel>();
        return Scaffold(
          appBar: commonAppBar(
            title: localization.request_appointment,
            elevation: Dimens.elevation,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.verticalspacing,
              ),
              child: Form(
                key: provider.formKey,
                autovalidateMode: provider.autoValidateMode,
                child: Column(
                  spacing: Dimens.textFromSpacing,
                  children: [
                    FormCommonDropDown<mla.Data>(
                      isRequired: true,
                      heading: localization.select_mla,
                      hintText: localization.choose_your_mla,
                      controller: provider.mlaController,
                      items: provider.mlaLists,
                      listItemBuilder: (p0, mla, p2, p3) {
                        return Text(
                          mla.user?.name ?? "",
                          style: textTheme.bodySmall,
                        );
                      },
                      headerBuilder: (p0, mla, p2) {
                        return Text(
                          mla.user?.name ?? "",
                          style: textTheme.bodySmall,
                        );
                      },
                      validator: (data) {
                        if (data == null) {
                          return localization.mla_validator;
                        }
                      },
                    ),
                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.name,
                      hintText: localization.enter_your_full_name,
                      controller: provider.nameController,
                      keyboardType: TextInputType.name,
                      validator: (text) =>
                          text?.validate(argument: localization.name_validator),
                    ),
                    FormTextFormField(
                      maxLength: 10,
                      isRequired: true,
                      headingText: localization.phone_number,
                      hintText: localization.enter_mobile_number,
                      controller: provider.phoneNumberController,
                      keyboardType: TextInputType.number,
                      validator: (text) => text?.validateNumber(
                        argument:
                            localization.please_provide_valid_10_digit_number,
                      ),
                    ),

                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.date,
                      hintText: localization.dd_mm_yyyy,
                      controller: provider.dateController,
                      suffixIcon: AppImages.calenderIcon,
                      showCursor: false,
                      onTap: () async {
                        final date = await customDatePicker();
                        if (date != null) {
                          provider.dateController.text = userDateFormat(date);
                          provider.companyDateFormat = companyDateFormat(date);
                        }
                      },
                      validator: (text) => text?.validate(
                        argument: localization.please_select_your_appointment_date,
                      ),
                    ),
                    FormCommonDropDown<String>(
                      isRequired: true,
                      heading: localization.time_slot,
                      hintText: localization.select_time_slot,
                      controller: provider.timeSlotController,
                      items: provider.timeSlotLists,
                    ),
                    FormCommonDropDown<String>(
                      isRequired: true,
                      heading: localization.purpose_of_appointment,
                      hintText: localization.select_purpose,
                      controller: provider.purposeOfAppointmentController,
                      items: provider.purposeLists,
                    ),
                    FormTextFormField(
                      isRequired: true,
                      headingText: localization.description,
                      hintText: localization.description_info,
                      controller: provider.descriptionController,
                      maxLines: 5,
                      validator: (text) => text?.validate(
                        argument: "Please enter description for appointment",
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
              ),
            ),
          ),
          bottomNavigationBar: Consumer<RequestAppointmentViewModel>(
            builder: (contextP, value, _) {
              return CommonButton(
                    isEnable: !value.isLoading,
                    isLoading: value.isLoading,
                    text: localization.submit_application,
                    onTap: () => value.requestNewAppointments(),
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
