import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/navigation/view/navigation_view.dart';
import 'package:inldsevak/features/navigation/view_model/navigation_view_model.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/disclaimer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isVisible = false;
      final prefs = await SharedPreferences.getInstance();
      isVisible = prefs.getBool('disclaimer_dismissed') ?? true;

      Future<void> dismissNotice() async {
        RouteManager.pop();
        isVisible = await prefs.setBool('disclaimer_dismissed', false);
      }

      if (isVisible) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return DraggableSheetWidget(
              onCompleted: dismissNotice,
              radius: Dimens.radiusX4,
              backgroundColor: Colors.amber[50],
              size: 0.24,
              child: DisclaimerNotice(onDismiss: dismissNotice),
            );
          },
        );
      }
    });
    super.initState();
  }

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
                return navigation.userWidgets[navigation.selectedTab];
              },
            ),
            extendBody: true,
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: NavigationView(),
          ),
        );
      },
    );
  }
}
