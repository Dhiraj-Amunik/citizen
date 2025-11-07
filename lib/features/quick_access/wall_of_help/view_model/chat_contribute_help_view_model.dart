import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_help_messages_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/help_message_model.dart'
    as message;

class ChatContributeHelpViewModel extends BaseViewModel with UploadFilesMixin {
  String arguments;

  ChatContributeHelpViewModel({required this.arguments});

  @override
  Future<void> onInit() {
    getChats();
    return super.onInit();
  }

  final WallOfHelpRepository repository = WallOfHelpRepository();
  final messageController = TextEditingController();

  List<message.MessagesDetails> messages = [];

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

  Future<void> getChats() async {
    try {
      isLoading = true;
      final response = await repository.getMessages(
        token: token,
        id: arguments,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.messagesDetails;

        messages.clear();
        List<message.MessagesDetails> tempList = [];
        tempList.addAll(List.from(data as List));
        messages.addAll(tempList.reversed);
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

  Future<void> replyMessage({required String financialID}) async {
    try {
      if (messageController.text.isEmpty && multipleFiles.isEmpty) {
        return;
      }

      isLoading = true;
// 68e7686710c77ebb6085c50b
      final data = RequestHelpMessageModel(
        messageID: arguments,
        financialHelpRequestId: financialID,
        messagesDetails: MessagesDetails(
          message: messageController.text,
          documents: multipleFiles.isEmpty
              ? []
              : await uploadMultipleImage(multipleFiles),
        ),
      );
      if (multipleFiles.isNotEmpty) {
        multipleFiles.clear();
      }
      final response = await repository.replyMessage(token: token, model: data);
      messageController.clear();
      if (response.data?.responseCode == 200) {
        if (arguments.isEmpty) {
          RouteManager.context.read<WallOfHelpViewModel>().onRefresh();
        }
        arguments = response.data?.data?.sId ?? "";
        getChats();
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
