import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/navigation/view/navigation_view.dart';
import 'package:inldsevak/features/navigation/view_model/navigation_view_model.dart';
import 'package:provider/provider.dart';
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

      if (isVisible) {
        // Mark as shown so other screens do not re-display the same notice
        // (prevents duplicate display when navigating immediately).
        await prefs.setBool('disclaimer_dismissed', false);
        if (!mounted) return;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (modalContext) {
            Future<void> dismissNotice() async {
              // Pop the modal bottom sheet using its own context

              await prefs.setBool('disclaimer_dismissed', false);
            }

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
        return Consumer<NavigationViewModel>(
          builder: (context, navigation, _) {
            return PopScope(
              canPop:
                  navigation.selectedTab == 0, // Only allow pop if on home tab
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  return; // Already popped, nothing to do
                }
                // If not on home tab, navigate to home tab instead of popping
                if (navigation.selectedTab != 0) {
                  navigation.selectedTab = 0;
                }
              },
              child: SafeArea(
                top: false,
                child: Scaffold(
                  body: navigation.userWidgets[navigation.selectedTab],
                  extendBody: true,
                  resizeToAvoidBottomInset: false,
                  bottomNavigationBar: NavigationView(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
