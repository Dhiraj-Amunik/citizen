import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/features/complaints/view/complaints_view.dart';
import 'package:inldsevak/features/donation/view/donate_view.dart';
import 'package:inldsevak/features/home/view/indl_view.dart';
import 'package:inldsevak/features/id_card/view/id_card_view.dart';
import 'package:inldsevak/features/lok_varta/view/lok_varta_view.dart';
import 'package:inldsevak/features/navigation/model/navigation_model.dart';
import 'package:inldsevak/features/profile/view/profile_view.dart';
import 'package:inldsevak/features/surveys/view/survey_view.dart';

class NavigationViewModel extends ChangeNotifier {
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  set selectedTab(int index) {
    if (selectedTab == index) {
      return;
    }
    _selectedTab = index;
    notifyListeners();
  }

  List<NavigationModel> userTabIconData = [
    NavigationModel(imagePath: AppImages.navINLDIcon, text: "INLD"),
    NavigationModel(imagePath: AppImages.navDonateIcon, text: "Donate"),
    NavigationModel(imagePath: AppImages.complaintAccess, text: "Complaint"),
    NavigationModel(imagePath: AppImages.aadharIcon, text: "Lok Varta"),
    NavigationModel(imagePath: AppImages.navProfileIcon, text: "Profile"),
  ];

  List<NavigationModel> partyTabIconData = [
    NavigationModel(imagePath: AppImages.navINLDIcon, text: "INLD"),
    NavigationModel(imagePath: AppImages.navSurveyIconIcon, text: "Survey"),
    NavigationModel(imagePath: AppImages.navIdCardIcon, text: "ID card"),
    NavigationModel(imagePath: AppImages.navMediaIcon, text: "Lok Varta"),
    NavigationModel(imagePath: AppImages.navProfileIcon, text: "Profile"),
  ];

  List<Widget> userWidgets = [
    IndlView(),
    DonateView(),
    ComplaintsView(),
    LokVartaView(),
    ProfileView(),
  ];

  List<Widget> partyWidgets = [
    IndlView(),
    SurveyView(),
    IdCardView(),
    LokVartaView(),
    ProfileView(),
  ];
}
