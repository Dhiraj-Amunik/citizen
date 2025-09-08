import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/donation/view/donate_view.dart';
import 'package:inldsevak/features/donation/view_model/donation_view_model.dart';
import 'package:inldsevak/restart_app.dart';
import 'package:provider/provider.dart';

class ContributeView extends StatelessWidget {
  const ContributeView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Scaffold(
      appBar: commonAppBar(title: localization.contribute),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.appBarSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${localization.request_details} :",
              style: textTheme.bodyLarge,
            ),
            SizeBox.sizeHX2,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX1,
              children: [
                getRow(text: localization.name, desc: "Ravi Kumar"),
                getRow(
                  text: localization.location,
                  desc: "Hyderabad, Telangana",
                ),
                getRow(text: localization.category, desc: "Health"),
                getRow(text: localization.requested_amount, desc: "2000"),
                getRow(
                  text: localization.description,
                  desc: "Medical Treatment",
                ),
                getRow(
                  text: localization.amount_already_contributed,
                  desc: "1000",
                ),
                getRow(text: localization.balance_needed, desc: "1000"),
                //
              ],
            ),

            Column(
              spacing: Dimens.widgetSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizeBox.size,
                FormTextFormField(
                  headingText: "${localization.enter_amount} :",
                  validator: (value) => value!.validateAmount(
                    argument: "Please enter minimum of 10rs",
                  ),
                  keyboardType: TextInputType.number,
                ),

                Text(localization.payment_options, style: textTheme.bodyMedium),
                iconBuilder(
                  icon: Icons.currency_rupee_sharp,
                  text: localization.razorpay,
                  textTheme: textTheme,
                ),
                iconBuilder(
                  icon: Icons.currency_rupee_sharp,
                  text: localization.upi,
                  textTheme: textTheme,
                ),
                iconBuilder(
                  icon: Icons.other_houses_outlined,
                  text: localization.net_banking,
                  textTheme: textTheme,
                ),
                iconBuilder(
                  icon: Icons.credit_card,
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
        child: CommonButton(
            onTap: () async {
              },
          text: localization.confirm,
        ),
      ),
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
