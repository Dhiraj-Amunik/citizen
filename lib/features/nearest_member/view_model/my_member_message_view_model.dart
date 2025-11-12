import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/nearest_member/model/my_member_chat_model.dart'
    as model;
import 'package:inldsevak/features/nearest_member/services/nearest_member_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';

class MyMemberMessageViewModel extends BaseViewModel {

  @override
  Future<void> onInit() {
    getAllChats();
    return super.onInit();
  }

  final NearestMemberRepository repository = NearestMemberRepository();

  List<model.Data> myChatsList = [];

  Future<void> getAllChats() async {
    try {
      isLoading = true;
      final response = await repository.getMyChats(token: token, );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;

        myChatsList.clear();
        myChatsList.addAll(List.from(data as List));
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.error);

        return;
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }
}
