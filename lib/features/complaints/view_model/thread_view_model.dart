import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/request/reply_request_model.dart';
import 'package:inldsevak/features/complaints/model/request/thread_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart';
import 'package:inldsevak/features/complaints/model/thread_model.dart';
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';

class ThreadViewModel extends BaseViewModel {
  final nextThreadController = TextEditingController();

  List<Data> threadsList = [];

  Future<List<Data>?> getThreads({required String threadID}) async {
    try {
      
      final data = ThreadRequestModel(threadID: threadID);

      final response = await ComplaintsRepository().getComplaintThread(
        data: data,
        token: await controller.getToken() ?? '',
      );
      if (response.data?.responseCode == 200) {
        threadsList.clear();
        List<Data> tempList = [];
        tempList.addAll(List.from(response.data?.data as List));
        threadsList.addAll(tempList.reversed);
      } else {
        CommonSnackbar(
          text: "Unable to fetch Complaints Records",
        ).showSnackbar();
      }
      return threadsList;
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      return threadsList;
    } finally {}
  }

  Future<void> replyThread({required ThreadModel model}) async {
    try {
      if (nextThreadController.text.isEmpty) {
        return;
      }
      isLoading = true;

      final data = ReplyRequestModel(
        to: model.to!,
        message: nextThreadController.text,
        subject: model.subject ?? "",
        threadId: model.threadID ?? "",
        inReplyTo: model.inReplyTo ?? "",
      );
      log(data.toJson().toString());

      final response = await ComplaintsRepository().replyComplaints(
        data: data,
        token: token ?? '',
      );
      if (response.data?.responseCode == 200) {
        nextThreadController.clear();
      } else {
        CommonSnackbar(
          text: response.data?.message ?? 'Something went wrong',
        ).showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }
}
