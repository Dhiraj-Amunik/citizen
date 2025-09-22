import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
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
      extendBody: false,
      appBar: commonAppBar(
        title: localization.contribute_with_love,
        action: [Icon(Icons.info_outline_rounded)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
        ).copyWith(bottom: Dimens.paddingX8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimens.paddingX3,
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
                          spacing: Dimens.gapX3,
                          children: [
                            Column(
                              spacing: Dimens.widgetSpacing,
                              children: [
                                CommonTextFormField(
                                  hintText: localization.enter_amount,
                                  controller: provider.amount,
                                  validator: (value) => value!.validateAmount(
                                    argument: "Please enter minimum of 10rs",
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                // CommonTextFormField(
                                //   hintText:
                                //       localization.enter_purpose_of_donation,
                                //   controller: provider.purpose,
                                //   focus: provider.purposeFocus,
                                //   validator: (value) => value!.validate(
                                //     argument: "Please provide a reason",
                                //   ),
                                // ),
                              ],
                            ),

                            Text(
                              'Your support, in any form, will help us create wonderful memories at this party.',
                              style: context.textTheme.labelMedium?.copyWith(
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
                          horizontal: Dimens.paddingX3,
                          vertical: Dimens.paddingX3,
                        ),
                  ),
                );
              },
            ),
            Text(localization.payment_options, style: textTheme.headlineSmall),
            Column(
              spacing: Dimens.gapX2,
              children: [
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
              ],
            ),

            Text(localization.donation_history, style: textTheme.headlineSmall),

            Consumer<DonationViewModel>(
              builder: (_, _, _) {
                return ListView.separated(
                  padding: EdgeInsets.zero,
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
            SizeBox.sizeHX14,
          ],
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
        backgroundColor: AppPalettes.liteGreenColor,
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
          spacing: Dimens.gapX2,
          children: [
            CommonHelpers.buildIcons(
              path: AppImages.clipboardIcon,
              padding: Dimens.paddingX2B,
              iconSize: Dimens.scaleX2,
              color: AppPalettes.liteGreenColor,
            ),

            Expanded(
              child: Column(
                spacing: Dimens.gapX,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹ $amount",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // SizeBox.sizeWX3,
                      // const Spacer(),

                      // SizeBox.sizeWX1,
                    ],
                  ),
                  Text(
                    date?.toDdMmmYyyy() ?? "",
                    style: textTheme.labelMedium?.copyWith(
                      color: AppPalettes.lightTextColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Text(
                  //   reason ?? "Purpose",
                  //   style: textTheme.labelMedium?.copyWith(
                  //     color: AppPalettes.lightTextColor,
                  //   ),
                  //   maxLines: 3,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                ],
              ),
            ),
          ],
        ).symmetricPadding(
          horizontal: Dimens.paddingX2,
          vertical: Dimens.paddingX2,
        ),
  );
}
