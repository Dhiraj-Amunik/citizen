import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/upload_image_widget.dart';
import 'package:inldsevak/features/home/view_model/request_membership_view_model.dart';
import 'package:provider/provider.dart';

class RequestMembershipView extends StatelessWidget {
  const RequestMembershipView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => RequestMembershipViewModel(),

      builder: (contextP, child) {
        final provider = contextP.read<RequestMembershipViewModel>();
        return Scaffold(
          appBar: commonAppBar(
            title: localization.request_membership,
            elevation: Dimens.elevation,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.verticalspacing,
              ),
              child: Column(
                spacing: Dimens.textFromSpacing,
                children: [
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
                    isRequired: true,
                    headingText: localization.contact_number,
                    hintText: localization.contact_number,
                    controller: provider.contactController,
                    keyboardType: TextInputType.number,
                    validator: (text) => text?.validateNumber(
                      argument: localization.please_provide_valid_10_digit_number,
                    ),
                  ),
                  FormTextFormField(
                    isRequired: true,
                    headingText: localization.aadhar_voter_id,
                    hintText: localization.enter_aadhar_voter,
                    controller: provider.aadharController,
                    keyboardType: TextInputType.text,
                    validator: (text) =>
                        text?.validate(argument: localization.aadhar_validator),
                  ),
                  FormTextFormField(
                    isRequired: true,
                    headingText: localization.address,
                    hintText: localization.enter_address,
                    controller: provider.addressController,
                    keyboardType: TextInputType.streetAddress,
                    validator: (text) =>
                        text?.validate(argument: localization.address_validator),
                  ),
                  Consumer<RequestMembershipViewModel>(
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
          bottomNavigationBar: Consumer<RequestMembershipViewModel>(
            builder: (contextP, value, _) {
              return CommonButton(
                    isEnable: !value.isLoading,
                    isLoading: value.isLoading,
                    text: localization.submit_application,
                    onTap: () {},
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
