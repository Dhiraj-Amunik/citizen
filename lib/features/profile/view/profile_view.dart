import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/helpers/profile_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/id_card/widgets/id_card_widget.dart';
import 'package:inldsevak/features/id_card/widgets/user_detail_widget.dart';
import 'package:inldsevak/features/navigation/view/navigation_view.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends StatelessWidget with CupertinoDialogMixin {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final roleProvider = context.read<RoleViewModel>();

    return Scaffold(
      appBar: commonAppBar(title: localization.profile),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.appBarSpacing,
        ),
        child: Column(
          spacing: Dimens.widgetSpacing,
          children: [
            Consumer<ProfileViewModel>(
              builder: (context, value, _) {
                return ProfileHelper.getProfileBox(
                  image: value.profile?.avatar,
                  name: value.profile?.name,
                  number: value.profile?.phone,
                  onTap: () => RouteManager.pushNamed(Routes.profileEditView),
                );
              },
            ),
            if (roleProvider.isPartyMember)
              Column(
                spacing: Dimens.widgetSpacing,
                children: [
                  Consumer<ProfileViewModel>(
                    builder: (context, value, _) {
                      return GestureDetector(
                        onTap: () => RouteManager.pushNamed(Routes.idCardPage),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.paddingX3,
                            vertical: Dimens.paddingX3,
                          ),
                          decoration: boxDecorationRoundedWithShadow(
                            Dimens.radiusX5,
                            backgroundColor: AppPalettes.liteGreyColor,
                          ),
                          child: Row(
                            spacing: Dimens.gapX2,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UserDetailWidget(
                                heading: context.textTheme.bodyMedium,
                                scale: Dimens.scaleX7,
                                profile: value.profile,
                              ),
                              QrCodeWidget(
                                height: 60,
                                data: value.profile?.membershipId ?? "",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ProfileHelper.getCommonBox(
                    localization.party_information,
                    subtext: localization.know_our_identity_slogan,
                    icon: AppImages.partyInfoProfileIcon,
                    onTap: () =>
                        RouteManager.pushNamed(Routes.partyInformationPage),
                  ),
                  ProfileHelper.getCommonBox(
                    localization.about_section,
                    subtext: localization.app_mission_vision_history,
                    icon: AppImages.aboutProfileIcon,
                    onTap: () => RouteManager.pushNamed(Routes.aboutPage),
                  ),
                  ProfileHelper.getCommonBox(
                    localization.leadership_information,
                    subtext: localization.meet_our_leaders_key_member,
                    icon: AppImages.leadershipProfileIcon,
                    onTap: () =>
                        RouteManager.pushNamed(Routes.leadershipInfoPage),
                  ),
                ],
              ),
            ProfileHelper.getCommonBox(
              localization.language,
              subtext: localization.language_subtext,
              icon: AppImages.translationIcon,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Container(
                        padding: EdgeInsets.all(Dimens.paddingX4),
                        decoration: BoxDecoration(
                          color: AppPalettes.whiteColor,
                          borderRadius: BorderRadius.circular(Dimens.paddingX4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizeBox.sizeHX5,
                            CommonButton(
                              color: AppPalettes.whiteColor,
                              textColor: AppPalettes.blackColor,
                              text: "English",
                              borderColor: AppPalettes.primaryColor,
                              onTap: () {
                                GeneralStream.instance.setLocale("en");
                                RouteManager.pop();
                              },
                            ),
                            SizeBox.sizeHX3,
                            CommonButton(
                              color: AppPalettes.whiteColor,
                              textColor: AppPalettes.blackColor,
                              text: "हिन्दी (Hindi)",
                              borderColor: AppPalettes.primaryColor,
                              onTap: () {
                                GeneralStream.instance.setLocale("hi");

                                RouteManager.pop();
                              },
                            ),
                            SizeBox.sizeHX5,
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            ProfileHelper.getCommonBox(
              localization.terms_and_conditions,
              subtext: localization.terms_and_conditions_subtext,
              icon: AppImages.termsServices,
              onTap: () =>
                  _launchURL("https://sites.google.com/view/inldsevak/home"),
            ),
            ProfileHelper.getCommonBox(
              localization.privacy_policy,
              subtext: localization.privacy_policy_subtext,
              icon: AppImages.privacyPolicy,
              onTap: () =>
                  _launchURL("https://sites.google.com/view/inldsevak/home"),
            ),
            ProfileHelper.getCommonBox(
              localization.help_and_support,
              subtext: localization.help_and_support_subtext,
              icon: AppImages.help,
              onTap: () => RouteManager.pushNamed(Routes.helpAndSupportPage),
            ),
            ProfileHelper.getCommonBox(
              localization.emergency_contacts,
              subtext: localization.emergency_contacts_subtext,
              icon: AppImages.phoneIcon,
              onTap: () => RouteManager.pushNamed(Routes.emergencyContactsPage),
            ),
            ProfileHelper.getCommonBox(
              localization.share_app,
              subtext: localization.share_app_subtext,
              icon: AppImages.shareIcon,
              backgroundColor: AppPalettes.liteGreenColor,
              onTap: () {
                SharePlus.instance.share(
                  ShareParams(
                    title: "SEVAK",
                    text:
                        'SEVAK App is the simple way to raise issues and get them delivered.\nhttps://play.google.com/store/apps/details?id=org.amunik.sevak&pcampaignid=web_share},',
                  ),
                );
              },
            ),
            ProfileHelper.getLogout(
              localization.logout,
              onTap: () {
                customLeftCupertinoDialog(
                  content: localization.logout_confirmation,
                  leftButton: localization.logout,
                  onTap: () async {
                    await SessionController.instance.clearSession();
                  },
                );
              },
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   spacing: Dimens.gapX2,
            //   children: [
            //     CommonHelpers.buildIcons(
            //       path: AppImages.instIcon,
            //       color: AppPalettes.liteGreyColor,
            //       padding: Dimens.paddingX3,
            //       iconSize: Dimens.scaleX3,
            //     ),
            //     CommonHelpers.buildIcons(
            //       path: AppImages.facebookIcon,
            //       color: AppPalettes.liteGreyColor,
            //       padding: Dimens.paddingX3,
            //       iconSize: Dimens.scaleX3,
            //     ),
            //     CommonHelpers.buildIcons(
            //       path: AppImages.twitterIcon,
            //       color: AppPalettes.liteGreyColor,
            //       padding: Dimens.paddingX3,
            //       iconSize: Dimens.scaleX3,
            //     ),
            //   ],
            // ),
            SizeBox.sizeHX9,
          ],
        ),
      ),
      bottomNavigationBar: DummyNav(),
    );
  }

  _launchURL(url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (err) {
      return CommonSnackbar(text: 'Could not launch $url').showToast();
    }
  }
}
