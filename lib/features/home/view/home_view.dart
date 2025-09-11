import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/navigation/view/navigation_view.dart';
import 'package:inldsevak/features/navigation/view_model/navigation_view_model.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleViewModel>(
      builder: (_, role, _) {
        if (!role.isUIEnabled) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return SafeArea(
          top: false,
          child: Scaffold(
            body: Consumer<NavigationViewModel>(
              builder: (_, navigation, _) {
                return role.isPartyMember
                    ? navigation.partyWidgets[navigation.selectedTab]
                    : navigation.userWidgets[navigation.selectedTab];
              },
            ).onlyPadding(bottom: Dimens.paddingX10),
            extendBody: true,

            bottomNavigationBar: Container(
              color: AppPalettes.transparentColor,
              child: NavigationView(),
            ),
          ),
        );
      },
    );
  }
}
