import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/profile_helper.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
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
              'Terms and Conditions',
              subtext: "App usage rules",
              icon: AppImages.termsServices,
            ),
            ProfileHelper.getCommonBox(
              'Privacy Policy',
              subtext: "Your data safety",
              icon: AppImages.privacyPolicy,
            ),
            ProfileHelper.getCommonBox(
              'Help & Support',
              subtext: "Get help and contact support",
              icon: AppImages.help,
              onTap: () => RouteManager.pushNamed(Routes.helpAndSupportPage),
            ),
            ProfileHelper.getCommonBox(
              'Emergency Contacts',
              subtext: "quick access to emergency services",
              icon: AppImages.phoneIcon,
              onTap: () => RouteManager.pushNamed(Routes.emergencyContactsPage),
            ),
            ProfileHelper.getLogout(
              'Logout',
              onTap: () async {
                await SessionController.instance.clearSession();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Dimens.gapX2,
              children: [
                CommonHelpers.buildIcons(
                  path: AppImages.instIcon,
                  color: AppPalettes.liteGreyColor,
                  padding: Dimens.paddingX3,
                  iconSize: Dimens.scaleX3,
                ),
                CommonHelpers.buildIcons(
                  path: AppImages.facebookIcon,
                  color: AppPalettes.liteGreyColor,
                  padding: Dimens.paddingX3,
                  iconSize: Dimens.scaleX3,
                ),
                CommonHelpers.buildIcons(
                  path: AppImages.twitterIcon,
                  color: AppPalettes.liteGreyColor,
                  padding: Dimens.paddingX3,
                  iconSize: Dimens.scaleX3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
