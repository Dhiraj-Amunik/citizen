import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/donation/view_model/donation_view_model.dart';
import 'package:provider/provider.dart';

class DonateView extends StatelessWidget {
  const DonateView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DonationViewModel>();
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: commonAppBar(elevation: 2, title: 'Contribute with love'),
      body: SingleChildScrollView(
        child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.widgetSpacing,
              children: [
                Consumer<DonationViewModel>(
                  builder: (_, _, _) {
                    return Form(
                      key: provider.donationFormKey,
                      autovalidateMode: provider.autoValidateMode,
                      child: Container(
                        decoration: boxDecorationRoundedWithShadow(
                          border: Border.all(color: AppPalettes.buttonColor),
                          Dimens.radiusX5,
                        ),
                        child:
                            Column(
                              spacing: Dimens.widgetSpacing,
                              children: [
                                CommonTextFormField(
                                  hintText: localization.enter_amount,
                                  controller: provider.amount,
                                  nextFocus: provider.purposeFocus,
                                  validator: (value) => value!.validateAmount(
                                    argument: "Please enter minimum of 10rs",
                                  ),
                                  keyboardType: TextInputType.number,
                                ),

                                CommonTextFormField(
                                  hintText:
                                      localization.enter_purpose_of_donation,
                                  controller: provider.purpose,
                                  focus: provider.purposeFocus,
                                  validator: (value) => value!.validate(
                                    argument: "Please provide a reason",
                                  ),
                                ),
                                Text(
                                  'Your support, in any form, will help us create wonderful memories at this party.',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppPalettes.lightTextColor,
                                  ),
                                ),
                                CommonButton(
                                  isEnable: !provider.isLoading,
                                  isLoading: provider.isLoading,
                                  onTap: () => provider.postDonation(),
                                  text: localization.donate,
                                ),
                              ],
                            ).symmetricPadding(
                              horizontal: Dimens.paddingX4,
                              vertical: Dimens.paddingX4,
                            ),
                      ),
                    );
                  },
                ),
                Text(localization.payment_options, style: textTheme.bodyLarge),
                iconBuilder(
                  icon: AppImages.rupeeIcon,
                  text: localization.razorpay,
                  textTheme: textTheme,
                ),
                iconBuilder(
                  icon: AppImages.rupeeIcon,
                  text: localization.upi,
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
                Text(localization.donation_history, style: textTheme.bodyLarge),

                Consumer<DonationViewModel>(
                  builder: (_, _, _) {
                    return ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final data = provider.pastDonations[index];
                        return donationWidget(
                          amount: data.amount,
                          reason: data.purpose,
                          date: data.createdAt,
                          textTheme: textTheme,
                        );
                      },
                      itemCount: provider.pastDonations.length,
                      separatorBuilder: (context, index) => SizeBox.sizeHX2,
                    );
                  },
                ),
              ],
            ).symmetricPadding(
              horizontal: Dimens.horizontalspacing,
              vertical: Dimens.verticalspacing,
            ),
      ),
    );
  }
}

Widget iconBuilder({
  required String icon,
  required String text,
  required TextTheme textTheme,
}) {
  return Row(
    spacing: Dimens.gapX3,
    children: [
      CircleAvatar(
        minRadius: Dimens.scaleX2B,
        backgroundColor: AppPalettes.gradientSecondColor,
        child: SvgPicture.asset(icon),
      ),
      Text(text, style: textTheme.bodyMedium),
    ],
  );
}

Widget donationWidget({
  required String? amount,
  required String? reason,
  required String? date,
  required TextTheme textTheme,
}) {
  return Container(
    decoration: boxDecorationRoundedWithShadow(
      Dimens.radiusX5,
      border: Border.all(color: AppPalettes.buttonColor),
    ),
    child:
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimens.gapX3,
          children: [
            CircleAvatar(
              minRadius: Dimens.scaleX2B,
              backgroundColor: AppPalettes.gradientSecondColor,
              child: SvgPicture.asset(AppImages.clipboardicon),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("₹ $amount", style: textTheme.bodySmall),
                  Text(
                    reason ?? "Purpose",
                    style: textTheme.bodySmall,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Expanded(
              child: Text(
                date?.toDdMmYyyy() ?? "",
                style: textTheme.bodySmall?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
            ),
          ],
        ).symmetricPadding(
          horizontal: Dimens.paddingX2,
          vertical: Dimens.paddingX2,
        ),
  );
}
