import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';
import 'package:inldsevak/features/notify_representative/services/notify_repository.dart';
import 'package:quickalert/quickalert.dart';

class UpdateNotifyRepresentativeViewModel extends BaseViewModel
    with UploadFilesMixin {
  late NotifyRepresentative notify;
  UpdateNotifyRepresentativeViewModel(NotifyRepresentative data) {
    addData(data);
    notify = data;
  }
  final _repository = NotifyRepository();

  @override
  Future<void> onInit() {
    getNotifyFilters();
    return super.onInit();
  }

  Future<void> getNotifyFilters() async {
    try {
      final response = await _repository.getNotifyFilters(token: token);
      if (response.data?.responseCode == 200) {
        filtersData = response.data?.data;
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error fetching filters: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final eventTypeController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final eventTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final streetController = TextEditingController();
  final pincodeController = TextEditingController();

  final districtController = TextEditingController();
  final mandalController = TextEditingController();
  final villageController = TextEditingController();
  final areaController = TextEditingController();
  final stateController = TextEditingController();
  final flatNoController = TextEditingController();
  final tehsilController = TextEditingController();
  final cityController = TextEditingController();

  String? companyDateFormat;
  LocationCoordinates? locationCoordinates;
  String? assemblyConstituenciesID;
  String? parliamentaryConstituenciesID;
  NotifyFiltersData? filtersData;

  List<File> multipleFiles = [];
  final List<String> _existingDocuments = [];
  List<String> get existingDocuments => List.unmodifiable(_existingDocuments);

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

  void removeImage(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  void removeExistingDocument(int index) {
    if (index < 0 || index >= _existingDocuments.length) return;
    _existingDocuments.removeAt(index);
    notifyListeners();
  }

  Future<void> requestNotify({
    required Function onCompleted,
  }) async {
    try {
      // Validate all form fields
      if (!formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      
      autoValidateMode = AutovalidateMode.disabled;
      isLoading = true;

      // Convert 12-hour format (with AM/PM) back to 24-hour format (HH:mm) for backend
      final timeIn24Hour = eventTimeController.text.trim().from12HourTo24HourFormat();
      
      final data = RequestNotifytModel(
        title: eventTypeController.text.trim(),
        location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
        eventDate: companyDateFormat ?? "",
        eventTime: timeIn24Hour,
        description: descriptionController.text.trim(),
        documents: [
          ..._existingDocuments,
          if (multipleFiles.isNotEmpty)
            ...await uploadMultipleImage(multipleFiles),
        ],
        id: notify.sId,
        district: districtController.text.trim(),
        mandal: mandalController.text.trim(),
        village: villageController.text.trim(),
        street: streetController.text.trim(),
        pincode: pincodeController.text.trim(),
        area: areaController.text.trim(),
        state: stateController.text.trim(),
        assemblyConstituency: null,
        parliamentaryConstituency: null,
        locationCoordinates: locationCoordinates,
      );

      final response = await _repository.createNotify(
        token: token,
        model: data,
      );

      if (response.data?.responseCode == 200) {
        // Successfully updated notify representative
        final updatedNotify = response.data?.data;
        if (updatedNotify != null) {
          debugPrint("Notify Representative updated with ID: ${updatedNotify.sId}");
        }
        onCompleted();
        await CommonSnackbar(
          text: response.data?.message ?? "Notify has been updated successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
        RouteManager.pop();
      } else {
        CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      CommonSnackbar(
        text: "Some thing went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  void loadAddressFromMapSearch(AddressModel? addressModel, MapSearchViewModel? mapSearchViewModel) {
    if (addressModel == null && mapSearchViewModel == null) return;
    
    // Prefer values from MapSearchViewModel controllers as they are already populated
    // Fallback to addressModel if controllers are empty
    // District should come from MapSearchViewModel as it may be updated by API
    final district = mapSearchViewModel?.districtController.text.isNotEmpty == true
        ? mapSearchViewModel!.districtController.text
        : (addressModel?.district ?? "");
    
    final area = mapSearchViewModel?.areaController.text.isNotEmpty == true
        ? mapSearchViewModel!.areaController.text
        : (addressModel?.area ?? addressModel?.subLocality ?? "");
    
    final tehsil = mapSearchViewModel?.tehsilController.text.isNotEmpty == true
        ? mapSearchViewModel!.tehsilController.text
        : (addressModel?.tehsil ?? "");
    
    final city = mapSearchViewModel?.cityController.text.isNotEmpty == true
        ? mapSearchViewModel!.cityController.text
        : (addressModel?.city ?? "");
    
    final state = mapSearchViewModel?.stateController.text.isNotEmpty == true
        ? mapSearchViewModel!.stateController.text
        : (addressModel?.state ?? "");
    
    final pincode = mapSearchViewModel?.pincodeController.text.isNotEmpty == true
        ? mapSearchViewModel!.pincodeController.text
        : (addressModel?.postalCode ?? "");
    
    // Map address fields from MapSearchViewModel to notify representative fields
    // Based on payload: village, street, mandal, district, pincode, area, state
    villageController.text = city.isNotEmpty ? city : (addressModel?.subLocality ?? "");
    streetController.text = area;
    mandalController.text = tehsil;
    // Always update district - this is critical
    districtController.text = district;
    pincodeController.text = pincode;
    areaController.text = area;
    stateController.text = state;
    
    // Also update MapSearchViewModel controllers for reference
    flatNoController.text = mapSearchViewModel?.flatNoController.text ?? 
        (addressModel?.houseNo ?? addressModel?.flatNo ?? "");
    tehsilController.text = tehsil;
    cityController.text = city;
    
    // Store location coordinates if available
    if (mapSearchViewModel?.currentPosition != null) {
      locationCoordinates = LocationCoordinates(
        lat: mapSearchViewModel!.currentPosition!.latitude,
        lng: mapSearchViewModel.currentPosition!.longitude,
      );
    } else if (addressModel?.latitude != null && addressModel?.longitude != null) {
      locationCoordinates = LocationCoordinates(
        lat: addressModel!.latitude!,
        lng: addressModel.longitude!,
      );
    }
    
    notifyListeners();
  }

  addData(NotifyRepresentative data) {
    eventTypeController.text = data.title ?? "";
    locationController.text = data.location ?? "";
    companyDateFormat = data.dateAndTime?.toYyyyMmDd();
    dateController.text = data.dateAndTime?.toDdMmYyyy() ?? "";
    eventTimeController.text = data.dateAndTime?.to24HourTime() ?? "";
    descriptionController.text = data.description ?? "";
    streetController.text = data.street ?? "";
    pincodeController.text = data.pincode ?? "";
    districtController.text = data.district ?? "";
    mandalController.text = data.mandal ?? "";
    villageController.text = data.village ?? "";
    areaController.text = data.area ?? "";
    stateController.text = data.state ?? "";
    
    // Store constituency IDs for editing
    // Use the values from the model, even if they're null (they might not be in list response)
    assemblyConstituenciesID = data.assemblyConstituency;
    parliamentaryConstituenciesID = data.parliamentaryConstituency;
    
    debugPrint("UpdateNotifyRepresentativeViewModel.addData - Assembly ID: $assemblyConstituenciesID, Parliamentary ID: $parliamentaryConstituenciesID");
    debugPrint("UpdateNotifyRepresentativeViewModel.addData - Model assemblyConstituency: ${data.assemblyConstituency}, parliamentaryConstituency: ${data.parliamentaryConstituency}");
    
    // Load existing data into MapSearchViewModel for editing
    // This allows "Use my location" to work with existing data
    // We'll populate what we have from the existing data
    // Note: This creates a new instance, but the actual MapSearchViewModel used in the view
    // is provided at a higher level, so we need to update it in the view's initState
    // The view will handle populating the actual MapSearchViewModel instance
    
    _existingDocuments
      ..clear()
      ..addAll(data.documents ?? const []);
  }
}
