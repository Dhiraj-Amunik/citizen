import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/nearest_member/model/member_messages_model.dart'
    as message;
import 'package:inldsevak/features/nearest_member/model/request_member_message_model.dart';
import 'package:inldsevak/features/nearest_member/services/nearest_member_repository.dart';
import 'package:quickalert/quickalert.dart';

class ChatMemberViewModel extends BaseViewModel with UploadFilesMixin {
  String id;
  String type;

  ChatMemberViewModel({required this.id, required this.type});

  @override
  Future<void> onInit() {
    getAllMessages();
    return super.onInit();
  }

  final NearestMemberRepository repository = NearestMemberRepository();
  final messageController = TextEditingController();

  List<message.MessagesDetails> messages = [];

  List<File> multipleFiles = [];

  Future<void> addFiles(Future<dynamic> future) async {
    // Note: Bottom sheet is already closed in handle_multiple_files_sheet.dart
    // No need to pop here as it would close the form page
    try {
      // Add delay to let system stabilize after image capture (critical for older devices)
      await Future.delayed(const Duration(milliseconds: 200));
      
      final data = await future;
      if (data != null && data is List) {
        // Validate files before adding
        final validFiles = <File>[];
        for (final item in data) {
          if (item is File) {
            try {
              if (await item.exists()) {
                final fileSize = await item.length();
                if (fileSize > 0 && fileSize < 5 * 1024 * 1024) {
                  validFiles.add(item);
                }
              }
            } catch (e) {
              debugPrint("Error validating file in addFiles: $e");
              // Continue with other files
            }
          }
        }
        
        if (validFiles.isEmpty) {
          CommonSnackbar(
            text: "No valid files to add. Please try again.",
          ).showAnimatedDialog(type: QuickAlertType.error);
          return;
        }
        
        List<File> tempFiles = [...multipleFiles];
        tempFiles.addAll(validFiles);
        if (tempFiles.length >= 6) {
          CommonSnackbar(
            text: "Max 5 Files are accepted",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          return;
        }
        
        multipleFiles.addAll(validFiles);
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error in addFiles: $err");
      debugPrint("Stack trace: $stackTrace");
      CommonSnackbar(
        text: "Failed to add files. Please try again.",
      ).showAnimatedDialog(type: QuickAlertType.error);
    }
  }

  void removefiles() {
    multipleFiles.clear();
    notifyListeners();
  }

  Future<void> getAllMessages() async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await repository.getMessages(
        token: token,
        id: id,
        type: type
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.messagesDetails;

        messages.clear();
        List<message.MessagesDetails> tempList = [];
        tempList.addAll(List.from(data as List));
        messages.addAll(tempList.reversed);
        notifyListeners();
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.error);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> replyMessage() async {
    try {
      if (messageController.text.isEmpty && multipleFiles.isEmpty) {
        return;
      }

      isLoading = true;

      final data = RequestMemberMessageModel(
        receiverId: id,
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
        await getAllMessages();
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
