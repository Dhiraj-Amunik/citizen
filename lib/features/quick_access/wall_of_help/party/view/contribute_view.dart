import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/donation/view/donate_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/contribute_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class ContributeView extends StatelessWidget {
  final model.Data helpRequest;

  const ContributeView({super.key, required this.helpRequest});

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   "${localization.request_details} :",
                //   style: textTheme.bodyLarge,
                // ),
                // SizeBox.sizeHX2,
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   spacing: Dimens.gapX1,
                //   children: [
                //     getRow(text: localization.name, desc: "Ravi Kumar"),
                //     getRow(
                //       text: localization.location,
                //       desc: "Hyderabad, Telangana",
                //     ),
                //     getRow(text: localization.category, desc: "Health"),
                //     getRow(text: localization.requested_amount, desc: "2000"),
                //     getRow(
                //       text: localization.description,
                //       desc: "Medical Treatment",
                //     ),
                //     getRow(
                //       text: localization.amount_already_contributed,
                //       desc: "1000",
                //     ),
                //     getRow(text: localization.balance_needed, desc: "1000"),
                //     //
                //   ],
                // ),
                Column(
                  spacing: Dimens.widgetSpacing,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<ContributeHelpViewModel>(
                      builder: (context, value, _) {
                        return Form(
                          key: value.formKey,
                          autovalidateMode: value.autoValidateMode,
                          child: FormTextFormField(
                            prefixIcon: AppImages.rupeeIcon,
                            textStyle: textTheme.titleMedium,
                            isRequired: true,
                            hintText: "$pendingAmount",
                            headingText: localization.enter_amount,
                            controller: value.amountController,
                            validator: (value) => value!.validateMaxAmount(
                              pendingAmount,
                              argument: "Please enter minimum of 10rs",
                              argument2:
                                  "Maximun amount is allowed $pendingAmount",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        );
                      },
                    ),

                    Text(
                      localization.payment_options,
                      style: textTheme.bodyMedium,
                    ),

                    iconBuilder(
                      icon: AppImages.rupeeIcon,
                      text: localization.upi,
                      textTheme: textTheme,
                    ),
                    iconBuilder(
                      icon: AppImages.rupeeIcon,
                      text: localization.razorpay,
                      textTheme: textTheme,
                    ),
                    iconBuilder(
                      icon: AppImages.bankIcon,
                      text: localization.net_banking,
                      textTheme: textTheme,
                    ),
                    iconBuilder(
                      icon: AppImages.cardsIcon,
                      text: localization.cards,
                      textTheme: textTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: Dimens.horizontalspacing,
              vertical: Dimens.verticalspacing,
            ),
            child: Consumer<ContributeHelpViewModel>(
              builder: (context, value, _) {
                return CommonButton(
                  isLoading: value.isLoading,
                  isEnable: !value.isLoading,
                  onTap: () => value.donateToHelpRequest(id: helpRequest.sId),
                  text: localization.confirm,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Widget getRow({required String text, String? desc}) {
  return RichText(
    text: TextSpan(
      style: AppStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
        color: AppPalettes.blackColor,
      ),
      children: [
        TextSpan(text: text),
        TextSpan(text: " : "),
        TextSpan(
          text: desc,
          style: AppStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w400,
            color: AppPalettes.blackColor,
          ),
        ),
      ],
    ),
  );
}
