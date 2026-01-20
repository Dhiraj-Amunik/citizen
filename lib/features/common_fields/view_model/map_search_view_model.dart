import 'package:flutter/material.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/services/search_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:geolocator/geolocator.dart';

class MapSearchViewModel extends ChangeNotifier with CupertinoDialogMixin {
  List<Predictions> searchplaces = [];
  AddressModel? address;

  Position? currentPosition;

  Map<String, String> _snapshotControllers() {
    return {
      'flat': flatNoController.text,
      'area': areaController.text,
      'pincode': pincodeController.text,
      'tehsil': tehsilController.text,
      'city': cityController.text,
      'district': districtController.text,
      'state': stateController.text,
    };
  }

  void _restoreControllers(Map<String, String> cached) {
    flatNoController.text = cached['flat'] ?? flatNoController.text;
    areaController.text = cached['area'] ?? areaController.text;
    pincodeController.text = cached['pincode'] ?? pincodeController.text;
    tehsilController.text = cached['tehsil'] ?? tehsilController.text;
    cityController.text = cached['city'] ?? cityController.text;
    districtController.text = cached['district'] ?? districtController.text;
    stateController.text = cached['state'] ?? stateController.text;
  }

  final flatNoController = TextEditingController();
  final areaController = TextEditingController();
  final tehsilController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  bool _shouldValidate = false;
  AutovalidateMode get addressAutovalidateMode =>
      _shouldValidate ? AutovalidateMode.always : AutovalidateMode.disabled;

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;
  set isEnabled(bool status) {
    _isEnabled = status;
    notifyListeners();
  }

  getCurrentLocation(Function(String) parlimentController) async {
    final cachedValues = _snapshotControllers();
    isEnabled = false;
    _shouldValidate = false;
    clear(safeClear: false);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await customRightCupertinoDialog(
          content:
              "Location services are disabled. Please enable them in settings.",
          rightButton: "Open Settings",
          onTap: () async {
            RouteManager.pop();
            await Geolocator.openLocationSettings();
          },
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        
        // If still denied after request, ask again
        if (permission == LocationPermission.denied) {
          await customRightCupertinoDialog(
            content: "Location permission is required to fetch your location. Please grant permission.",
            rightButton: "Grant Permission",
            onTap: () async {
              RouteManager.pop();
              // Request permission again
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.deniedForever) {
                await customRightCupertinoDialog(
                  content:
                      "Location permission is denied permanently. Please enable it in settings.",
                  rightButton: "Open Settings",
                  onTap: () async {
                    RouteManager.pop();
                    await Geolocator.openAppSettings();
                  },
                );
                return;
              }
            },
          );
          // If permission is still denied, return early
          if (permission == LocationPermission.denied) {
            _restoreControllers(cachedValues);
            return;
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await customRightCupertinoDialog(
          content:
              "Location permission is denied permanently. Please enable it in settings.",
          rightButton: "Open Settings",
          onTap: () async {
            RouteManager.pop();
            await Geolocator.openAppSettings();
          },
        );
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        try {
          currentPosition = await Geolocator.getCurrentPosition();
        } catch (e) {
          debugPrint("⚠️ Error getting current position: $e");
          // Check if error is due to permission
          if (e.toString().contains('permission') || e.toString().contains('denied')) {
            // Re-check permission and retry
            permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always) {
                try {
                  currentPosition = await Geolocator.getCurrentPosition();
                } catch (e2) {
                  debugPrint("⚠️ Error getting position after permission retry: $e2");
                }
              } else if (permission == LocationPermission.deniedForever) {
                await customRightCupertinoDialog(
                  content:
                      "Location permission is denied permanently. Please enable it in settings.",
                  rightButton: "Open Settings",
                  onTap: () async {
                    RouteManager.pop();
                    await Geolocator.openAppSettings();
                  },
                );
                _restoreControllers(cachedValues);
                return;
              }
            }
          }
          // Try last known position as fallback
          if (currentPosition == null) {
            try {
              currentPosition = await Geolocator.getLastKnownPosition();
            } catch (e2) {
              debugPrint("⚠️ Error getting last known position: $e2");
            }
          }
        }
      }

      if (currentPosition == null) {
        await CommonSnackbar(
          text: "Unable to fetch your current location. Please try again.",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        _restoreControllers(cachedValues);
        return;
      }

      await getLoactionByCoordinates(parlimentController);
      if (address == null) {
        _restoreControllers(cachedValues);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      // Check if error is due to permission
      if (err.toString().contains('permission') || err.toString().contains('denied')) {
        // Re-check permission and retry
        try {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always) {
              try {
                currentPosition = await Geolocator.getCurrentPosition();
                if (currentPosition != null) {
                  await getLoactionByCoordinates(parlimentController);
                  if (address == null) {
                    _restoreControllers(cachedValues);
                  }
                  return;
                }
              } catch (e) {
                debugPrint("⚠️ Error getting position after permission retry in catch: $e");
              }
            }
          }
        } catch (e) {
          debugPrint("⚠️ Error checking permission in catch: $e");
        }
      }
      await CommonSnackbar(
        text: "Something went wrong while fetching your location.",
      ).showAnimatedDialog(type: QuickAlertType.error);
      _restoreControllers(cachedValues);
    } finally {
      isEnabled = true;
    }
  }

  Future<void> getLoactionByCoordinates(
    Function(String) parlimentController,
  ) async {
    try {
      final response = await GoogleRepository().placeFromCoordinates(
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
      );
      if (response.data?.status == "OK") {
        final addressModel = AddressModel.fromGeocodingModel(response.data!);
        address = addressModel;
      }
      if (address != null) {
        loadAddress(model: address);
        // Add a delay to ensure controllers are updated and listeners are triggered
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Debug: Print address details to verify parsing
        debugPrint("📍 Address loaded - District: ${address?.district ?? 'null'}, Area: ${address?.area ?? 'null'}, City: ${address?.city ?? 'null'}, Tehsil: ${address?.tehsil ?? 'null'}");
        debugPrint("📍 Controllers - District: ${districtController.text}, Area: ${areaController.text}, City: ${cityController.text}");
        
        await parlimentController(pincodeController.text);
        // Trigger listeners again to ensure sync happens after all updates
        await Future.delayed(const Duration(milliseconds: 100));
        notifyListeners();
        return;
      }

      await CommonSnackbar(
        text: "No Address found please try again",
      ).showAnimatedDialog(type: QuickAlertType.warning);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      await CommonSnackbar(
        text: "Unable to load address details. Please try again.",
      ).showAnimatedDialog(type: QuickAlertType.error);
    }
  }

  Future<List<Predictions>> getSearchPlaces(String placeName) async {
    searchplaces.clear();
    clear();
    try {
      final response = await GoogleRepository().searchLocation(
        placeName: placeName,
      );
      if (response.data?.status == "OK") {
        searchplaces = List<Predictions>.from(
          response.data?.predictions as List,
        );
        return searchplaces;
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return [];
  }

  Future<Position?> getLocationByPlaceID(
    String placeID, {
    Future<void>? task,
  }) async {
    try {
      final response = await GoogleRepository().getLocationByPlaceID(
        placeID: placeID,
      );
      if (response.data?.status == "OK") {
        final latitude = response.data?.result?.geometry?.location?.lat;
        final longitude = response.data?.result?.geometry?.location?.lng;

        return Position(
          longitude: longitude ?? 0,
          latitude: latitude ?? 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

      } else {
        await CommonSnackbar(
          text: "No Address found please try again",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return null;
  }

  clear({bool safeClear = true}) {
    if (safeClear) {
      pincodeController.clear();
      flatNoController.clear();
      areaController.clear();
      tehsilController.clear();
      cityController.clear();
      districtController.clear();
      stateController.clear();
      currentPosition = null;
      address = null;
    }
    _shouldValidate = false;
    searchplaces.clear();
  }

  loadAddress({AddressModel? model}) {
    pincodeController.text = model?.postalCode ?? "";
    stateController.text = model?.state ?? "";
    districtController.text = model?.district ?? "";
    cityController.text = model?.city ?? "";
    tehsilController.text = model?.tehsil ?? "";
    flatNoController.text = model?.houseNo ?? model?.flatNo ?? "";
    areaController.text = model?.area ?? model?.subLocality ?? "";
    _shouldValidate = true;
    notifyListeners(); // Trigger listeners to sync with other view models
  }
}


/*
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
  AddressModel? addressModel;



  // Future<List<Predictions>> getSearchPlaces(String placeName) async {
  //   searchplaces.clear();
  //   clear();
  //   try {
  //     final response = await SearchRepository().searchLocation(
  //       placeName: placeName,
  //     );
  //     if (response.data?.status == "OK") {
  //       searchplaces = List<Predictions>.from(
  //         response.data?.predictions as List,
  //       );
  //       return searchplaces;
  //     }
  //   } catch (err, stackTrace) {
  //     debugPrint("Error: $err");
  //     debugPrint("Stack Trace: $stackTrace");
  //   }
  //   return [];
  // }

  
  // searchplaces.clear();

*/

/*



Future<void> getLocationByPlaceID(String placeID) async {
    try {
      showCustomDialogTransperent(isShowing: true);
      final response = await SearchRepository().getLocationByPlaceID(
        placeID: placeID,
      );
      if (response.data?.status == "OK") {
        final latitude = response.data?.result?.geometry?.location?.lat;
        final longitude = response.data?.result?.geometry?.location?.lng;
        if (latitude != null && longitude != null) {
          final response2 = await SearchRepository().getPinCode(
            lat: latitude,
            lng: longitude,
          );
          if (response2.data?.status == "OK" && response2.data != null) {
            addressModel = AddressModel.fromPinCodeModel(response2.data!);
            if (addressModel != null) {
              pincodeController.text = addressModel?.pincode ?? "";
              stateController.text = addressModel?.state ?? "";
              districtController.text = addressModel?.district ?? "";
              cityController.text = addressModel?.city ?? "";
              addressModel?.latitude = latitude;
              addressModel?.longitude = longitude;
              if (pincodeController.text.isNotEmpty) {
                if (RouteManager.context.mounted) {
                  await RouteManager.context
                      .read<ConstituencyViewModel>()
                      .getParliamentaryConstituencies(
                        pincode: int.tryParse(pincodeController.text),
                      );

                  notifyListeners();
                  return;
                }
              }
            }
          }
        }
      }
      return await CommonSnackbar(
        text: "No Address found please try again",
      ).showAnimatedDialog(type: QuickAlertType.warning);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      showCustomDialogTransperent(isShowing: false);
    }
  }
  
  */