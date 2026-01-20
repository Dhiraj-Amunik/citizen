import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/donation/view_model/donation_view_model.dart';
import 'package:inldsevak/features/donation/widget/donation_dialog.dart';
import 'package:inldsevak/features/navigation/view_model/navigation_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateView extends StatefulWidget {
  const DonateView({super.key});

  @override
  State<DonateView> createState() => _DonateViewState();
}

class _DonateViewState extends State<DonateView> with WidgetsBindingObserver {
  int? _previousTab;
  bool _hasLaunchedPaymentApp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final navigationViewModel = context.read<NavigationViewModel>();
        _previousTab = navigationViewModel.selectedTab;
        navigationViewModel.addListener(_onTabChanged);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (mounted) {
      final navigationViewModel = context.read<NavigationViewModel>();
      navigationViewModel.removeListener(_onTabChanged);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasLaunchedPaymentApp) {
      // App resumed after launching payment app, clear the form
      final donationViewModel = context.read<DonationViewModel>();
      donationViewModel.clear();
      _hasLaunchedPaymentApp = false;
    }
  }

  void _onTabChanged() {
    if (!mounted) return;
    final navigationViewModel = context.read<NavigationViewModel>();
    final currentTab = navigationViewModel.selectedTab;
    
    // Clear donation form when switching away from donate tab (tab index 1)
    if (_previousTab == 1 && currentTab != 1) {
      final donationViewModel = context.read<DonationViewModel>();
      donationViewModel.clear();
    }
    _previousTab = currentTab;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DonationViewModel>();
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return Scaffold(
      extendBody: false,
      appBar: commonAppBar(title: localization.contribute_with_love),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
        ).copyWith(bottom: Dimens.paddingX8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimens.paddingX4,
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
                            CommonTextFormField(
                              hintText: 'Enter Amount in (₹)',
                              controller: provider.amount,
                              maxLength: 10,
                              validator: (value) => value!.validateAmount(
                                argument: "Please enter minimum of 10rs",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            TranslatedText(
                              text: 'Your support, in any form, will help us create wonderful memories at this party.',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppPalettes.lightTextColor,
                              ),
                            ).onlyPadding(left: Dimens.paddingX1),
                          ],
                        ).symmetricPadding(
                          horizontal: Dimens.paddingX3,
                          vertical: Dimens.paddingX3B,
                        ),
                  ),
                );
              },
            ),
          Container(
            width: double.infinity,
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX4,
           
              border: Border.all(color: AppPalettes.primaryColor),
            ),
            child: Column(
              spacing: Dimens.gapX,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TranslatedText(text:  'UPI ID: ',style: textTheme.bodySmall?.copyWith(color: AppPalettes.blackColor,fontWeight: FontWeight.w500)),
                    TranslatedText(text: '9988090768m@pnb',style: textTheme.bodySmall?.copyWith(color: AppPalettes.lightTextColor,fontWeight: FontWeight.w400)),
                  ],
                ),
                Row(
                  children: [
                    TranslatedText(text: 'Name: ',style: textTheme.bodySmall?.copyWith(color: AppPalettes.blackColor,fontWeight: FontWeight.w500)),
                    TranslatedText(text: 'Indian National Lokdal',style: textTheme.bodySmall?.copyWith(color: AppPalettes.lightTextColor,fontWeight: FontWeight.w400)),
                  ],
                ),
                Row(
                  children: [
                    TranslatedText(text: 'Bank Name: ',style: textTheme.bodySmall?.copyWith(color: AppPalettes.blackColor,fontWeight: FontWeight.w500)),
                    TranslatedText(text: 'Punjab National Bank',style: textTheme.bodySmall?.copyWith(color: AppPalettes.lightTextColor,fontWeight: FontWeight.w400)),
                  ],
                ),
                Row(
                  children: [
                    TranslatedText(text: 'Account No: ',style: textTheme.bodySmall?.copyWith(color: AppPalettes.blackColor,fontWeight: FontWeight.w500)),
                    TranslatedText(text: '1504002100125555',style: textTheme.bodySmall?.copyWith(color: AppPalettes.lightTextColor,fontWeight: FontWeight.w400)),
                  ],
                ),
                Row(
                  children: [
                    TranslatedText(text: 'IFS Code: ',style: textTheme.bodySmall?.copyWith(color: AppPalettes.blackColor,fontWeight: FontWeight.w500)),
                    TranslatedText(text: 'PUNB0148800',style: textTheme.bodySmall?.copyWith(color: AppPalettes.lightTextColor,fontWeight: FontWeight.w400)),
                  ],
                ),

              ],
            ).symmetricPadding(horizontal: Dimens.horizontalspacing,vertical: Dimens.verticalspacing),
          ),
            Text(
              localization.select_payment_options,
              style: textTheme.headlineSmall,
            ),
            Consumer<DonationViewModel>(
              builder: (_, _, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimens.gapX2,
                  children: [
                    // iconBuilder(
                    //   icon: AppImages.rupeeIcon,
                    //   text: localization.razorpay,
                    //   textTheme: textTheme,
                    // ),
                    GestureDetector(
                      onTap: () {
                        provider.isUpiSelected = true;
                      },
                      child: iconBuilder(
                        isSelected: provider.isUpiSelected,
                        icon: AppImages.rupeeIcon,
                        text: localization.upi,
                        textTheme: textTheme,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        provider.isNetSelected = true;
                      },
                      child: iconBuilder(
                        isSelected: provider.isNetSelected,
                        icon: AppImages.bankIcon,
                        text: localization.net_banking,
                        textTheme: textTheme,
                      ),
                    ),
                    // iconBuilder(
                    //   icon: AppImages.cardsIcon,
                    //   text: localization.cards,
                    //   textTheme: textTheme,
                    // ),
                  ],
                );
              },
            ),
            CommonButton(
              isEnable: !provider.isLoading,
              isLoading: provider.isLoading,
              onTap: () async {
                // Validate amount before proceeding
                final amountText = provider.amount.text.trim();
                
                if (amountText.isEmpty) {
                  CommonSnackbar(text: "Please enter amount").showToast();
                  return;
                }
                
                try {
                  final amount = int.parse(amountText);
                  if (amount < 10) {
                    CommonSnackbar(text: "Please enter minimum of 10rs").showToast();
                    return;
                  }
                } catch (e) {
                  CommonSnackbar(text: "Please enter a valid amount").showToast();
                  return;
                }
                
                if (await provider.manualDonation()) {
                  if (provider.isUpiSelected) {
                    final launched = await launchUrl(
                      Uri.parse(
                        'upi://pay?pa=9988090768m@pnb&pn=INDIAN NATIONAL LOKDAL&am=${provider.amount.text}&cu=INR',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                    // Mark that we launched payment app - will clear when app resumes
                    if (launched) {
                      _hasLaunchedPaymentApp = true;
                    }
                  }

                  if (provider.isNetSelected) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return DraggableSheetWidget(
                          showClose: true,
                          size: 0.65,
                          child: Column(
                            spacing: Dimens.gapX2,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                localization.net_banking,
                                style: context.textTheme.headlineSmall,
                              ),
                              TranslatedText(
                                text: "Please donate to the below account details",
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppPalettes.lightTextColor,
                                ), 
                              ),
                              showBankDetails(
                                title: "Bank Name",
                                copyText: "Punjab national bank",
                              ),
                              showBankDetails(
                                title: "Account No",
                                copyText: "1504002100125555",
                              ),
                              showBankDetails(
                                title: "IFS Code",
                                copyText: "PUNB0148800",
                              ),
                            ],
                          ).symmetricPadding(horizontal: Dimens.widgetSpacing,vertical: Dimens.paddingX2),
                        );
                      },
                    );
                    // Note: For net banking, we don't clear immediately since it's just a modal
                    // The form will be cleared when user switches tabs (handled in _onTabChanged)
                  }
                }
              },
              text: localization.donate,
            ),
            DonationDialog(),
            // Text(localization.donation_history, style: textTheme.headlineSmall),
            // Consumer<DonationViewModel>(
            //   builder: (_, _, _) {
            //     return ListView.separated(
            //       padding: EdgeInsets.zero,
            //       physics: NeverScrollableScrollPhysics(),
            //       shrinkWrap: true,
            //       itemBuilder: (context, index) {
            //         final data = provider.pastDonations[index];
            //         return donationWidget(
            //           amount: data.amount,
            //           reason: data.purpose,
            //           date: data.createdAt,
            //           textTheme: textTheme,
            //         );
            //       },
            //       itemCount: provider.pastDonations.length,
            //       separatorBuilder: (context, index) => SizeBox.sizeHX2,
            //     );
            //   },
            // ),
            SizeBox.sizeHX14,
          ],
        ),
      ),
    );
  }

  Widget showBankDetails({required String title, required String copyText}) {
    return FormCommonChild(
      heading: title,

      child: Container(
        padding: EdgeInsets.only(
          left: Dimens.paddingX4,
          right: Dimens.paddingX,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          backgroundColor: AppPalettes.liteGreenColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              copyText,
              style: AppStyles.bodySmall.copyWith(
                color: AppPalettes.lightTextColor,
              ),
            ),
            CommonHelpers.buildIcons(
              padding: Dimens.paddingX2B,
              iconSize: Dimens.scaleX3,
              path: AppImages.copyIcon,
              onTap: () {
                Clipboard.setData(ClipboardData(text: copyText));
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget iconBuilder({
  bool isSelected = false,
  required String icon,
  required String text,
  required TextTheme textTheme,
}) {
  return Container(
    decoration: BoxDecoration(
      color: isSelected ? AppPalettes.liteGreenColor : null,
      borderRadius: BorderRadius.circular(Dimens.radiusX4),
      border: Border.all(color: AppPalettes.primaryColor),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: Dimens.paddingX2,
      vertical: Dimens.paddingX2,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      spacing: Dimens.gapX3,
      children: [
        CircleAvatar(
          minRadius: Dimens.scaleX2,
          backgroundColor: isSelected
              ? AppPalettes.whiteColor
              : AppPalettes.liteGreenColor,
          child: SvgPicture.asset(icon),
        ),
        Text(text, style: textTheme.bodyMedium),
      ],
    ),
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
