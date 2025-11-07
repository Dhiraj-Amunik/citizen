import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/utils/url_launcher.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/donation/view/donate_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/get_help_details.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/contribute_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:quickalert/quickalert.dart';

class ContributeView extends StatelessWidget {
  final model.FinancialRequest helpRequest;

  const ContributeView({super.key, required this.helpRequest});

  @override
  Widget build(BuildContext context) {
    log(helpRequest.toJson().toString());
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final pendingAmount =
        (helpRequest.amountRequested ?? 0) - (helpRequest.amountCollected ?? 0);
    return ChangeNotifierProvider(
      create: (context) => ContributeHelpViewModel(),
      builder: (context, _) {
        return Scaffold(
          appBar: commonAppBar(title: localization.contribute),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
            child: Column(
              spacing: Dimens.widgetSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(Dimens.paddingX3B),
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX3,
                    border: Border.all(color: AppPalettes.primaryColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Dimens.gapX1B,
                    children: [
                      Text(
                        "${localization.request_details} :",
                        style: textTheme.headlineSmall,
                      ),
                      SizeBox.size,
                      getHelpDetails(
                        text: localization.name,
                        desc: helpRequest.name,
                      ),
                      getHelpDetails(
                        text: localization.location,
                        desc: helpRequest.address,
                      ),
                      getHelpDetails(
                        text: localization.category,
                        desc: helpRequest.typeOfHelp?.name?.capitalize(),
                      ),
                      getHelpDetails(
                        text: localization.requested_amount,
                        desc: (helpRequest.amountRequested ?? 0).toString(),
                      ),
                      getHelpDetails(
                        text: localization.description,
                        desc: helpRequest.description,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(Dimens.paddingX3B),
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX3,
                    border: Border.all(color: AppPalettes.primaryColor),
                  ),
                  child: Consumer<ContributeHelpViewModel>(
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Dimens.gapX3,
                        children: [
                          Text(
                            "${localization.contribution_input} :",
                            style: textTheme.headlineSmall,
                          ),

                          Form(
                            key: value.formKey,
                            autovalidateMode: value.autoValidateMode,
                            child: FormTextFormField(
                              prefixIcon: AppImages.rupeeIcon,
                              textStyle: textTheme.titleMedium,
                              isRequired: true,
                              hintText: "$pendingAmount",
                              controller: value.amountController,
                              validator: (value) => value!.validateMaxAmount(
                                pendingAmount,
                                argument: "Please enter minimum of 10rs",
                                argument2:
                                    "Maximun amount is allowed $pendingAmount",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),

                          CommonButton(
                            isLoading: value.isLoading,
                            isEnable: !value.isLoading,
                            onTap: () {
                              if (helpRequest.uPI?.isEmpty == true) {
                                CommonSnackbar(
                                  text: "Unable to Process this Transcation",
                                ).showAnimatedDialog(
                                  type: QuickAlertType.error,
                                );
                              } else {
                                if (value.amountController.text.isEmpty) {
                                  UrlLauncher().launchURL(
                                    'upi://pay?pa=${helpRequest.uPI}',
                                  );
                                } else {
                                  UrlLauncher().launchURL(
                                    'upi://pay?pa=${helpRequest.uPI}&am=${value.amountController.text}&cu=INR',
                                  );
                                }
                              }

                              //
                            },
                            text: localization.confirm,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                Column(
                  spacing: Dimens.gapX3,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.select_payment_options,
                      style: textTheme.headlineSmall,
                    ),
                    iconBuilder(
                      isSelected: true,
                      icon: AppImages.rupeeIcon,
                      text: localization.upi,
                      textTheme: textTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
