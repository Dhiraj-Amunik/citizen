import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/request/complaint_by_id_request_model.dart';
import 'package:inldsevak/features/complaints/model/request/complaint_case_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart'
    as threads;
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:quickalert/quickalert.dart';

class ThreadViewModel extends BaseViewModel {
  final Data arguments;

  ThreadViewModel({required this.arguments}) {
    onCreated(complaintId: arguments.sId);
  }

  onCreated({String? complaintId}) async {
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
  threads.ComplaintThreadData? complaintData;

  Future<void> getThreads() async {
    try {
      loadMessages = true;

      // Use complaintId (sId) from arguments instead of threadId
      if (arguments.sId == null || arguments.sId!.isEmpty) {
        CommonSnackbar(text: "Complaint ID not found").showSnackbar();
        loadMessages = false;
        return;
      }

      final data = ComplaintByIdRequestModel(complaintId: arguments.sId!);

      final response = await ComplaintsRepository().getComplaintByThreadId(
        data: data,
        token: token,
      );
      if (response.data?.responseCode == 200) {
        threadsList.clear();
        
        // Handle changed API response structure
        // New structure: response.data?.data is an object with messages array
        // Old structure: response.data?.data is a list of messages
        
        if (response.data?.complaintData != null) {
          // Store complaint data for use in replies
          complaintData = response.data!.complaintData;
          notifyListeners();
          // New structure: extract messages from complaintData
          final messages = response.data!.complaintData!.messages;
          if (messages != null && messages.isNotEmpty) {
            threadsList = messages.map((msg) => threads.Data.fromMessage(msg)).toList();
            threadsList = threadsList.reversed.toList();
          }
        } else if (response.data?.data != null && response.data!.data!.isNotEmpty) {
          // Old structure: data is a list
          List<threads.Data> tempList = [];
          tempList.addAll(response.data!.data!);
          threadsList.addAll(tempList.reversed);
        } else {
          debugPrint("⚠️ No messages found in response");
        }
      } else {
        final errorMessage = response.data?.message ?? "Unable load messages !";
        CommonSnackbar(text: errorMessage).showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      CommonSnackbar(text: "Error loading messages").showSnackbar();
    } finally {
      loadMessages = false;
    }
  }

  Future<void> replyThread({
    required String id,
    String? status,
  }) async {
    try {
      // Allow sending if either message has text or files are attached
      if (nextThreadController.text.trim().isEmpty && multipleFiles.isEmpty) {
        return CommonSnackbar(text: "Message or image is required").showToast();
      }
      isLoading = true;

      List<MultipartFile> multipartFiles = [];
      for (File imagePath in multipleFiles) {
        MultipartFile file = await MultipartFile.fromFile(imagePath.path);
        multipartFiles.add(file);
      }

      // If message is empty but files are attached, send a space as placeholder
      // This satisfies API requirement for non-empty message without showing visible text
      // Get the exact text the user typed, trimmed of whitespace
      // IMPORTANT: Use only what's in the controller, don't add any extra text
      String messageText = nextThreadController.text.trim();
      if (messageText.isEmpty && multipleFiles.isNotEmpty) {
        messageText = " "; // Single space placeholder when sending only images
      }
      
      // Debug: Log the exact message being sent to verify it's correct
      debugPrint("📤 Message being sent: '$messageText'");
      debugPrint("📤 Message length: ${messageText.length}");
      debugPrint("📤 Controller text before trim: '${nextThreadController.text}'");

      // Get department, authority, and subject from complaint data
      // Use complaintData if available (from thread response), otherwise use arguments
      String? departmentId = complaintData?.department?.sId ?? arguments.department?.sId;
      String? authorityId = complaintData?.authority?.authorityId ?? complaintData?.authority?.sId;
      String? subject = arguments.messages?.isNotEmpty == true 
          ? arguments.messages!.first.subject 
          : complaintData?.messages?.isNotEmpty == true
              ? complaintData!.messages!.first.subject
              : "Re: Complaint";

      // Validate required fields for reply
      if (departmentId == null || departmentId.isEmpty) {
        CommonSnackbar(text: "Department information not found").showToast();
        isLoading = false;
        return;
      }

      if (authorityId == null || authorityId.isEmpty) {
        CommonSnackbar(text: "Authority information not found").showToast();
        isLoading = false;
        return;
      }

      // Build FormData to match Postman format
      // All text fields must be sent as strings, files as list
      final Map<String, dynamic> formDataMap = {
        "department": departmentId.toString(),
        "authority": authorityId.toString(),
        "subject": (subject ?? "Re: Complaint").toString(),
        "message": messageText,
        "complaintId": id.toString(), // Include complaintId for replies
      };

      // Add status if provided
      if (status != null && status.isNotEmpty) {
        formDataMap["status"] = status.toString();
      }

      // Add attachments as a list (Dio handles multiple files with same key)
      if (multipartFiles.isNotEmpty) {
        formDataMap["attachments"] = multipartFiles;
      }

      debugPrint("📤 Reply Form data keys: ${formDataMap.keys}");
      debugPrint("📤 Department: $departmentId");
      debugPrint("📤 Authority: $authorityId");
      debugPrint("📤 ComplaintId: $id");
      debugPrint("📤 Subject: ${subject ?? "Re: Complaint"}");
      debugPrint("📤 Attachments count: ${multipartFiles.length}");

      // Create FormData - Dio will handle multipart/form-data encoding
      final FormData form = FormData.fromMap(formDataMap);

      final response = await ComplaintsRepository().replyComplaints(
        data: form,
        token: token,
      );
      if (response.data?.responseCode == 200) {
        removefiles();
        getThreads();
        // Clear the controller after successful send
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

  Future<bool> submitComplaintCase({
    required String complaintId,
    required String response,
    FeedbackModel? feedback,
    String? date,
  }) async {
    try {
      isLoading = true;
      
      final requestModel = ComplaintCaseRequestModel(
        complaintId: complaintId,
        response: response,
        feedback: feedback,
        date: date,
      );

      final responseData = await ComplaintsRepository().complaintCase(
        data: requestModel,
        token: token,
      );

      if (responseData.data?.responseCode == 200) {
        // Refresh the threads to get updated data
        await getThreads();
        return true;
      } else {
        CommonSnackbar(
          text: responseData.data?.message ?? 'Something went wrong',
        ).showToast();
        return false;
      }
    } catch (err, stackTrace) {
      debugPrint("Error submitting complaint case: $err");
      debugPrint("Stack Trace: $stackTrace");
      CommonSnackbar(text: "Error submitting response").showToast();
      return false;
    } finally {
      isLoading = false;
    }
  }
}