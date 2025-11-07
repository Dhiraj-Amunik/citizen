import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/request/thread_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart'
    as threads;
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:quickalert/quickalert.dart';

class ThreadViewModel extends BaseViewModel {
  final Data arguments;

  ThreadViewModel({required this.arguments}) {
    onCreated(id: arguments.threadId!);
  }

  onCreated({required String id}) async {
    await initialize();
    await getThreads();
  }

  final nextThreadController = TextEditingController();

  bool _loadMessages = false;
  bool get loadMessages => _loadMessages;
  set loadMessages(bool value) {
    _loadMessages = value;
    notifyListeners();
  }

  List<threads.Data> threadsList = [];

  Future<void> getThreads() async {
    try {
      loadMessages = true;

      final data = ThreadRequestModel(threadID: arguments.threadId!);

      final response = await ComplaintsRepository().getComplaintThread(
        data: data,
        token: token,
      );
      if (response.data?.responseCode == 200) {
        threadsList.clear();
        List<threads.Data> tempList = [];
        tempList.addAll(List.from(response.data?.data as List));
        threadsList.addAll(tempList.reversed);
      } else {
        CommonSnackbar(text: "Unable load messages !").showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      loadMessages = false;
    }
  }

  Future<void> replyThread({required String id}) async {
    try {
      if (nextThreadController.text.isEmpty) {
        return CommonSnackbar(text: "Message can't be empty").showToast();
      }
      isLoading = true;

      List<MultipartFile> multipartFiles = [];
      for (File imagePath in multipleFiles) {
        MultipartFile file = await MultipartFile.fromFile(imagePath.path);
        multipartFiles.add(file);
      }

      final FormData form = FormData.fromMap({
        "message": nextThreadController.text.trim(),
        "complaintId": id,
        "attachments": multipartFiles,
      });

      final response = await ComplaintsRepository().replyComplaints(
        data: form,
        token: token,
      );
      if (response.data?.responseCode == 200) {
        removefiles();
        getThreads();
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

  // Add Files

  List<File> multipleFiles = [];

  Future<void> addFiles(Future<dynamic> future) async {
    RouteManager.pop();
    try {
      final data = await future;
      if (data != null) {
        List<File> tempFiles = [...multipleFiles];
        tempFiles.addAll(data);
        if (tempFiles.length >= 6) {
          return CommonSnackbar(
            text: "Max 5 Files are accepted",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
          multipleFiles.addAll(await future);
          notifyListeners();
        }
      }
    } catch (err) {
      debugPrint("-------->$err");
    }
  }

  void removefiles() {
    multipleFiles.clear();
    notifyListeners();
  }
}