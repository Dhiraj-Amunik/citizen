import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/complaints/model/request/request_authorities_model.dart';
import 'package:inldsevak/features/complaints/model/response/authorites_model.dart'
    as authorities;
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart'
    as departments;
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class AddComplaintsViewModel extends BaseViewModel
    with CupertinoDialogMixin, TransparentCircular, UploadFilesMixin {
  @override
  Future<void> onInit() async {
    await super.onInit();
    // Initialize token first, then load departments
    await initialize();
    // Load departments after initialization
    getDepartments().catchError((error) {
      debugPrint("Error loading departments: $error");
    });
  }

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final departmentController = SingleSelectController<departments.Data>(null);
  final authortiyController = SingleSelectController<authorities.Authority>(
    null,
  );
  String selectedLevel = "Level 1";
  List<String> escalationLevels = ["Level 1", "Level 2", "Level 3"];

  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  List<departments.Data> departmentLists = [];
  List<authorities.Data> allOfficers = [];
  List<authorities.Authority> filteredAuthorities = [];
  update() {
    notifyListeners();
  }

  Future<void> lodgeComplaints({required String constituencyID}) async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      isLoading = true;
      List<MultipartFile> multipartFiles = [];
      for (File imagePath in multipleFiles) {
        MultipartFile file = await MultipartFile.fromFile(imagePath.path);
        multipartFiles.add(file);
      }

      debugPrint("🚀 Submitting complaint title: ${titleController.text}");
      debugPrint("📝 Title code units: ${titleController.text.codeUnits}");

      // Validate required fields before building form data
      final departmentId = departmentController.value?.sId;
      if (departmentId == null || departmentId.isEmpty) {
        CommonSnackbar(text: "Please select a department").showToast();
        isLoading = false;
        notifyListeners();
        return;
      }

      // Get authority ID - API expects _id (sId) value, NOT authorityId
      // From API response: "_id": "68b80817655a85b13fa99124" is the correct field to send
      // authorityId like "AUTH692CDDEC" should NOT be used
      final selectedAuthority = authortiyController.value;

      if (selectedAuthority == null) {
        debugPrint("❌ No authority selected");
        CommonSnackbar(text: "Please select an authority").showToast();
        isLoading = false;
        notifyListeners();
        return;
      }

      // Use the selected authority level record ID
      String? authorityId = selectedAuthority.sId;

      if (authorityId == null || authorityId.isEmpty) {
        debugPrint("❌ Authority _id (sId) is null or empty");
        debugPrint("   Full authority object: $selectedAuthority");
        CommonSnackbar(text: "Please select a valid authority").showToast();
        isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint("✅ Using Authority _id (sId): $authorityId");

      // Build FormData to match Postman format
      // All text fields must be sent as strings, files as list
      // Mapping:
      // - titleController (complaint_title field) → "subject" (displayed as title in complaint widget)
      // - descriptionController (description field) → "message" (displayed as snippet/description in complaint widget)
      final Map<String, dynamic> formDataMap = {
        "department": departmentId.toString(),
        "authority": authorityId.toString(),
        "subject": titleController
            .text, // From complaint_title field (lines 90-102 in lodge_complaint_view.dart)
        "message": descriptionController
            .text, // From description field (lines 156-168 in lodge_complaint_view.dart)
      };

      // Add attachments as a list (Dio handles multiple files with same key)
      if (multipartFiles.isNotEmpty) {
        formDataMap["attachments"] = multipartFiles;
      }

      // DO NOT include complaintId for new complaints
      // complaintId should only be included when replying

      debugPrint("📤 Form data keys: ${formDataMap.keys}");
      debugPrint(
        "📤 Department: $departmentId (length: ${departmentId.length})",
      );
      debugPrint("📤 Authority: $authorityId (length: ${authorityId.length})");
      debugPrint("📤 Subject: ${titleController.text}");
      debugPrint("📤 Message: ${descriptionController.text}");
      debugPrint("📤 Attachments count: ${multipartFiles.length}");
      debugPrint("📤 FormData map: $formDataMap");

      // Create FormData - Dio will handle multipart/form-data encoding
      final FormData form = FormData.fromMap(formDataMap);

      // Log FormData fields for debugging
      debugPrint("📤 FormData fields count: ${form.fields.length}");
      debugPrint("📤 FormData files count: ${form.files.length}");
      for (var field in form.fields) {
        debugPrint("📤 Field: ${field.key} = ${field.value}");
      }

      final response = await ComplaintsRepository().addComplaints(
        data: form,
        token: token ?? '',
      );

      // Check for error first - this must be checked before checking success
      if (response.error != null) {
        debugPrint("❌ API Error: ${response.error}");
        final errorMessage =
            response.error?.message ?? "Failed to lodge complaint";
        CommonSnackbar(text: errorMessage).showToast();
        isLoading = false;
        notifyListeners();
        return;
      }

      // Handle response - API returns: {responseCode: 200, message: "...", data: {...}}
      // The repository already checks for responseCode != 200 and returns error
      // So if we get here without error, it means responseCode == 200 (success)
      // Also check if we have data (either success field or data object)
      bool isSuccess = false;
      if (response.data != null) {
        final data = response.data;
        // Check for success field (old format) OR if data exists (new format with responseCode)
        if (data?.success == true) {
          isSuccess = true;
          debugPrint("✅ Success via success field");
        } else if (data != null) {
          // If data exists and no error, treat as success
          // The repository already validated responseCode == 200
          isSuccess = true;
          debugPrint("✅ Success via responseCode 200 (data exists)");
        } else {
          debugPrint("⚠️ Response data is null");
          isSuccess = false;
        }
      } else {
        debugPrint("⚠️ No response data");
        isSuccess = false;
      }

      if (isSuccess) {
        // Set loading to false before showing dialog
        isLoading = false;
        notifyListeners();

        // Clear form data before showing dialog
        clearForm();

        // Get context before showing dialog
        final BuildContext? dialogContext =
            RouteManager.navigatorKey.currentState?.context;

        // First, refresh the complaints list
        if (dialogContext != null && dialogContext.mounted) {
          try {
            final provider = dialogContext.read<ComplaintsViewModel>();
            provider.selectedStatusList = [];
            provider.departmentKey = null;
            // Load complaints before navigating
            provider.getComplaints(showLoader: true);
          } catch (e) {
            debugPrint("Error refreshing complaints: $e");
          }
        }

        // Show success dialog and wait for user to tap OK
        await CommonSnackbar(
          text: 'Complaints has been Lodged',
        ).showAnimatedDialog(type: QuickAlertType.success);

        // After dialog is fully closed (user tapped OK), navigate
        // Wait a bit to ensure dialog is completely dismissed
        await Future.delayed(const Duration(milliseconds: 300));

        // Pop the lodge complaint view first, then push complaints view
        // This ensures clean navigation stack: Previous -> Complaints (not Previous -> Lodge -> Complaints)
        // Replace the lodge complaint view with complaints view directly
        // This avoids flashing the underlying screen (like INDLView)
        final navContext = RouteManager.navigatorKey.currentState?.context;
        if (navContext != null && navContext.mounted) {
          try {
            await RouteManager.pushReplacementNamed(Routes.complaintsPage);
          } catch (e) {
            debugPrint("Error navigating to complaints view: $e");
          }
        }
      } else {
        CommonSnackbar(text: 'Something went wrong').showToast();
        isLoading = false;
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDepartments() async {
    try {
      // Ensure token is available before making API call
      if (token == null || token!.isEmpty) {
        debugPrint("⚠️ Token not available for getDepartments");
        // Retry after a short delay if token might still be loading
        Future.delayed(Duration(milliseconds: 500), () {
          if (token != null && token!.isNotEmpty) {
            getDepartments();
          }
        });
        return;
      }

      debugPrint("🔍 Calling GET /api/user/list-of-department-dropdown");
      showCustomDialogTransperent(isShowing: true);
      final response = await ComplaintsRepository().getDepartments(token);

      if (response.error != null) {
        debugPrint("❌ API Error: ${response.error?.message}");
        departmentLists = [];
        notifyListeners();
        showCustomDialogTransperent(isShowing: false);
        return;
      }

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data == null) {
          debugPrint("⚠️ Departments data is null in response");
          departmentLists = [];
          notifyListeners();
        } else if (data.isEmpty) {
          debugPrint("⚠️ No departments found in response (empty list)");
          departmentLists = [];
          CommonSnackbar(text: "No departments found").showToast();
          notifyListeners();
        } else {
          try {
            // Data is already parsed as List<departments.Data> from the model
            departmentLists = data;
            debugPrint(
              "✅ Successfully loaded ${departmentLists.length} departments",
            );
            // Log first department for debugging
            if (departmentLists.isNotEmpty) {
              final firstDept = departmentLists.first;
              debugPrint(
                "   Example department - Name: ${firstDept.name}, sId: ${firstDept.sId}, departmentId: ${firstDept.departmentId}",
              );
            }
            notifyListeners();
          } catch (e, stackTrace) {
            debugPrint("❌ Error assigning departments: $e");
            debugPrint("Stack trace: $stackTrace");
            debugPrint("   Data type: ${data.runtimeType}");
            debugPrint("   Data content: $data");
            departmentLists = [];
            notifyListeners();
          }
        }
      } else {
        debugPrint("⚠️ Failed to get departments: ${response.data?.message}");
        debugPrint("   Response code: ${response.data?.responseCode}");
        departmentLists = [];
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("❌ Exception in getDepartments: $err");
      debugPrint("Stack Trace: $stackTrace");
      departmentLists = [];
      notifyListeners();
    } finally {
      // Always dismiss loading dialog
      showCustomDialogTransperent(isShowing: false);
    }
  }

  Future<void> getAuthorities({required String? id}) async {
    try {
      allOfficers.clear();
      filteredAuthorities.clear();
      authortiyController.clear();
      notifyListeners();

      if (id == null || id.isEmpty) return;

      if (token == null || token!.isEmpty) return;

      showCustomDialogTransperent(isShowing: true);

      final model = RequestAuthoritiesModel(departemnetID: id);
      final response = await ComplaintsRepository().getAuthorites(
        token: token,
        data: model,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data != null) {
          allOfficers = data;
          filterByLevel(selectedLevel);
        }
      }
    } catch (err) {
      debugPrint("❌ Exception in getAuthorities: $err");
    } finally {
      showCustomDialogTransperent(isShowing: false);
    }
  }

  void filterByLevel(String level) {
    selectedLevel = level;
    filteredAuthorities = [];

    for (var officer in allOfficers) {
      // Handle new API structure (level1Details) - all items are level 1
      if (officer.level1Details != null) {
        // New API format: each officer is already a level 1 authority
        if (level.trim().toLowerCase().contains("level 1") ||
            level.trim().toLowerCase() == "1" ||
            officer.level1Details!.level?.trim().toLowerCase().contains(
                  "level 1",
                ) ==
                true) {
          // Create Authority object from level1Details
          // Use root name (officer.name) as primary, as it's the authority's actual name
          // IMPORTANT: Use officer.sId (main authority _id) not level1Details.sId for API submission
          final auth = authorities.Authority(
            level: officer.level1Details!.level ?? "Level 1",
            email:
                officer.level1Details!.email ??
                (officer.email?.isNotEmpty == true
                    ? officer.email!.first
                    : null),
            index: officer.level1Details!.index,
            name:
                officer.name ??
                officer
                    .level1Details!
                    .name, // Prioritize root name (authority name)
            sId: officer
                .sId, // Use main authority _id (not level1Details._id) - this is what API expects
          );
          filteredAuthorities.add(auth);
        }
      }
      // Handle old API structure (nested authority array) - for backward compatibility
      else if (officer.authority != null) {
        for (var auth in officer.authority!) {
          if (auth.level?.trim() == level.trim()) {
            if (auth.name == null || auth.name!.isEmpty) {
              auth.name = officer.name;
            }
            filteredAuthorities.add(auth);
          }
        }
      }
    }

    authortiyController.clear();
    notifyListeners();
  }

  //image
  List<File> multipleFiles = [];
  // Camera lock to prevent double-tap crashes on low-RAM devices
  bool _isCameraOpening = false;

  Widget selectMultipleImages({BuildContext? context}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.camera),
          title: TranslatedText(text: 'Take a Picture'),
          onTap: () {
            // 🔥 SAFE: Close bottom sheet first, then wait for next frame
            final navContext =
                context ?? RouteManager.navigatorKey.currentState?.context;
            if (navContext != null) {
              Navigator.of(navContext, rootNavigator: true).pop();
              // Wait for bottom sheet to fully dispose before opening camera
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openCameraSafely();
              });
            } else {
              _openCameraSafely();
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: TranslatedText(text: 'Choose from Gallery'),
          onTap: () async {
            final navContext =
                context ?? RouteManager.navigatorKey.currentState?.context;
            if (navContext != null) {
              Navigator.of(navContext, rootNavigator: true).pop();
            }
            try {
              multipleFiles.addAll(await pickMultipleImages());
              notifyListeners();
            } catch (err) {
              debugPrint("-------->$err");
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.file_open),
          title: TranslatedText(text: 'Choose from Files'),
          onTap: () async {
            final navContext =
                context ?? RouteManager.navigatorKey.currentState?.context;
            if (navContext != null) {
              Navigator.of(navContext, rootNavigator: true).pop();
            }
            try {
              multipleFiles.addAll(await pickFiles());
              notifyListeners();
            } catch (err) {
              debugPrint("-------->$err");
            }
          },
        ),
      ],
    );
  }

  /// 🔥 SAFE CAMERA OPEN - Prevents crashes on low-RAM devices
  /// Uses lock to prevent double-tap, waits for bottom sheet disposal
  Future<void> _openCameraSafely() async {
    // Prevent double-tap camera launch (causes crash on low-RAM devices)
    if (_isCameraOpening) return;
    _isCameraOpening = true;

    try {
      // Extra delay for low-RAM devices to ensure widget tree is stable
      await Future.delayed(const Duration(milliseconds: 400));

      final file = await createCameraImage();

      // Additional delay after image capture to let system stabilize (critical for older devices)
      await Future.delayed(const Duration(milliseconds: 300));

      if (file != null) {
        try {
          // Validate file exists and is valid
          if (await file.exists()) {
            final fileSize = await file.length();
            // Check file size is reasonable (max 5MB) and greater than 0
            if (fileSize > 0 && fileSize < 5 * 1024 * 1024) {
              // Use microtask to ensure UI is ready before processing
              await Future.microtask(() {
                multipleFiles.add(file);
                notifyListeners();
              });
            } else {
              CommonSnackbar(
                text: "Image file is too large or invalid. Please try again.",
              ).showAnimatedDialog(type: QuickAlertType.error);
            }
          } else {
            CommonSnackbar(
              text: "Image file not found. Please try again.",
            ).showAnimatedDialog(type: QuickAlertType.error);
          }
        } catch (fileErr) {
          debugPrint("Error validating file: $fileErr");
          CommonSnackbar(
            text: "Failed to process image. Please try again.",
          ).showAnimatedDialog(type: QuickAlertType.error);
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error capturing image: $err");
      debugPrint("Stack trace: $stackTrace");
      CommonSnackbar(
        text: "Failed to capture image. Please try again.",
      ).showAnimatedDialog(type: QuickAlertType.error);
    } finally {
      // Additional delay before releasing lock to prevent rapid re-triggers
      await Future.delayed(const Duration(milliseconds: 200));
      _isCameraOpening = false;
    }
  }

  void removeImage(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  /// Clear all form data and controllers
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    departmentController.clear();
    authortiyController.clear();
    multipleFiles.clear();
    autoValidateMode = AutovalidateMode.disabled;
    formKey.currentState?.reset();
    notifyListeners();
  }
}
