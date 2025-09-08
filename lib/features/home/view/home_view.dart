import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/navigation/screen/navigation_view.dart';
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
        return Scaffold(
          body: Consumer<NavigationViewModel>(
            builder: (_, navigation, _) {
              return role.isPartyMember
                  ? navigation.partyWidgets[navigation.selectedTab]
                  : navigation.userWidgets[navigation.selectedTab];
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Visibility(
            visible:
                role.isPartyMember==false &&
                MediaQuery.of(context).viewInsets.bottom == 0.0,
            child: FloatingActionButton(
              shape: CircleBorder(),
              backgroundColor: AppPalettes.primaryColor,
              tooltip: "Add Complaints",
              child: Icon(Icons.add, color: AppPalettes.whiteColor),
              onPressed: () {
                RouteManager.pushNamed(Routes.complaintsPage);
              },
            ),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(top: Dimens.paddingX1),
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX2,
              shadowColor: AppPalettes.liteGreyColor,
              blurRadius: 2,
              backgroundColor: AppPalettes.transparentColor,
            ),
            child: BottomAppBar(
              notchMargin: Dimens.marginX1,
              shape: CircularNotchedRectangle(),
              child: NavigationView(),
            ),
          ),
        );
      },
    );
  }
}
