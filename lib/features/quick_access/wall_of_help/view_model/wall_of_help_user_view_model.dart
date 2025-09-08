import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class WallOfHelpUserViewModel extends BaseViewModel {
  
  @override
  Future<void> onInit() {
    getWallOfHelpList();
    return super.onInit();
  }

  List<model.Data> wallOFHelpLists = [];

  Future<void> getWallOfHelpList() async {
    try {
      isLoading = true;
      final response = await WallOfHelpRepository().getWallOFHelp(token);

      if (response.data?.responseCode == 200) {
        wallOFHelpLists.clear();
        final data = response.data?.data;
        if (data?.isNotEmpty == true) {
          wallOFHelpLists.addAll(List.from(data as List));
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }
}
