import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/services/notify_repository.dart';
import 'package:quickalert/quickalert.dart';

class CreateNotifyRepresentativeViewModel extends BaseViewModel
    with UploadFilesMixin {
  final _repository = NotifyRepository();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final eventTypeController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final eventTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final streetController = TextEditingController();
  final pincodeController = TextEditingController();

  final mlaController = SingleSelectController<MlaFilter>(null);
  final districtController = TextEditingController();
  final mandalController = TextEditingController();
  final villageController = TextEditingController();
  final areaController = TextEditingController();
  final stateController = TextEditingController();
  final flatNoController = TextEditingController();
  final tehsilController = TextEditingController();
  final cityController = TextEditingController();
  
  String? assemblyConstituenciesID;
  String? parliamentaryConstituenciesID;

  String? companyDateFormat;
  LocationCoordinates? locationCoordinates;
  NotifyFiltersData? filtersData;

  List<File> multipleFiles = [];

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

  Future<void> addFiles(Future<dynamic> future) async {
    // Note: Bottom sheet is already closed in handle_multiple_files_sheet.dart
    // No need to pop here as it would close the form page
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

  void removeImage(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  /// Syncs address fields from MapSearchViewModel to this view model
  /// This ensures all address fields are up-to-date before submission
  void syncAddressFieldsFromMapSearch(MapSearchViewModel? mapSearchViewModel) {
    if (mapSearchViewModel == null) return;
    
    // Sync all address fields directly from MapSearchViewModel controllers
    districtController.text = mapSearchViewModel.districtController.text;
    areaController.text = mapSearchViewModel.areaController.text;
    stateController.text = mapSearchViewModel.stateController.text;
    pincodeController.text = mapSearchViewModel.pincodeController.text;
    mandalController.text = mapSearchViewModel.tehsilController.text;
    streetController.text = mapSearchViewModel.areaController.text;
    villageController.text = mapSearchViewModel.cityController.text.isNotEmpty
        ? mapSearchViewModel.cityController.text
        : (mapSearchViewModel.address?.subLocality ?? "");
    
    // Store location coordinates
    if (mapSearchViewModel.currentPosition != null) {
      locationCoordinates = LocationCoordinates(
        lat: mapSearchViewModel.currentPosition!.latitude,
        lng: mapSearchViewModel.currentPosition!.longitude,
      );
    } else if (mapSearchViewModel.address?.latitude != null && 
               mapSearchViewModel.address?.longitude != null) {
      locationCoordinates = LocationCoordinates(
        lat: mapSearchViewModel.address!.latitude!,
        lng: mapSearchViewModel.address!.longitude!,
      );
    }
  }

  Future<void> requestNotify({
    required Function onCompleted,
    MapSearchViewModel? mapSearchViewModel,
  }) async {
    try {
      // Sync address fields from MapSearchViewModel before validation
      // This ensures all fields are up-to-date even if async sync didn't complete
      syncAddressFieldsFromMapSearch(mapSearchViewModel);
      
      // Validate all form fields including dropdown
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
        documents: multipleFiles.isEmpty
            ? []
            : await uploadMultipleImage(multipleFiles),
        mlaId: mlaController.value?.sId,
        locationCoordinates: locationCoordinates,
        district: districtController.text.trim(),
        mandal: mandalController.text.trim(),
        village: villageController.text.trim(),
        street: streetController.text.trim(),
        pincode: pincodeController.text.trim(),
        area: areaController.text.trim(),
        state: stateController.text.trim(),
        assemblyConstituency: null,
        parliamentaryConstituency: null,
      );

      final response = await _repository.createNotify(
        token: token,
        model: data,
      );

      // Get localization for error messages
      final localization = RouteManager.navigatorKey.currentState?.context.localizations;
      
      // Check for repository errors first
      if (response.error != null) {
        CommonSnackbar(
          text: response.error?.message ?? localization?.something_went_wrong ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.error);
        return;
      }

      // Check response code
      if (response.data?.responseCode == 200) {
        // Successfully created notify representative
        final createdNotify = response.data?.data;
        if (createdNotify != null) {
          debugPrint("Notify Representative created with ID: ${createdNotify.sId}");
        }
        onCompleted();
        await CommonSnackbar(
          text: response.data?.message ?? "Notify has been requested successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
        RouteManager.pop();
      } else {
        CommonSnackbar(
          text: response.data?.message ?? localization?.something_went_wrong ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      final localization = RouteManager.navigatorKey.currentState?.context.localizations;
      CommonSnackbar(
        text: localization?.something_went_wrong ?? "Something went wrong",
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

  clear() {
    eventTypeController.clear();
    locationController.clear();
    companyDateFormat = "";
    dateController.clear();
    eventTimeController.clear();
    descriptionController.clear();
    streetController.clear();
    pincodeController.clear();
    mlaController.value = null;
    districtController.clear();
    mandalController.clear();
    villageController.clear();
    areaController.clear();
    stateController.clear();
    flatNoController.clear();
    tehsilController.clear();
    cityController.clear();
    assemblyConstituenciesID = null;
    parliamentaryConstituenciesID = null;
    locationCoordinates = null;
    multipleFiles..clear();
  }
}
