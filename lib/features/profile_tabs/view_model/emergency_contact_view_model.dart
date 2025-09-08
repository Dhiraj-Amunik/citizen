import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/features/profile_tabs/model/emergency_contacts_model.dart';

class EmergencyContactViewModel extends ChangeNotifier {

  EmergencyContactViewModel(){
    buildList();
  }
  List<EmergencyContactsModel> emergencyContactsList = [];

  void buildList() {
    final localization =
        RouteManager.navigatorKey.currentState!.context.localizations;
    emergencyContactsList = [
      EmergencyContactsModel(
        title: localization.emergency_help,
        description: localization.emergency_help_info,
        number: "18001900",
        icon: AppImages.emergencyHelpIcon
      ),
      EmergencyContactsModel(
        title: localization.police_emergency,
        description: localization.police_emergency_info,
        number: "100",
        icon: AppImages.policeEmgIcon

      ),
      EmergencyContactsModel(
        title: localization.fire_department,
        description: localization.fire_department_info,
        number: "101",
        icon: AppImages.fireDeptIcon

      ),
      EmergencyContactsModel(
        title: localization.ambulance,
        description: localization.ambulance_info,
        number: "108",
        icon: AppImages.ambulanceIcon

      ),
      EmergencyContactsModel(
        title: localization.electricity_board,
        description: localization.electricity_board_info,
        number: "1912",
        icon: AppImages.electricBoardIcon

      ),
      EmergencyContactsModel(
        title: localization.water_department,
        description: localization.water_department_info,
        number: "1916",
        icon: AppImages.waterDeptIcon

      ),
    ];
    notifyListeners();
  }
}
