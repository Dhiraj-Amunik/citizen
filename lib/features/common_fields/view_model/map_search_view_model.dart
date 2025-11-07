import 'dart:developer';

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

  final flatNoController = TextEditingController();
  final areaController = TextEditingController();
  final tehsilController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;
  set isEnabled(bool status) {
    _isEnabled = status;
    notifyListeners();
  }

  getCurrentLocation(Function(String) parlimentController) async {
    isEnabled = false;
    clear();
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition();
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        currentPosition = await Geolocator.getCurrentPosition();
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
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition();
    }

    isEnabled = true;

    if (currentPosition != null) {
      await getLoactionByCoordinates(parlimentController);
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
        await parlimentController(pincodeController.text);
        return;
      }

      return await CommonSnackbar(
        text: "No Address found please try again",
      ).showAnimatedDialog(type: QuickAlertType.warning);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
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

  clear({bool? safeClear = true}) {
    if (safeClear == true) {
      pincodeController.clear();
    }
    address = null;
    currentPosition = null;
    cityController.clear();
    districtController.clear();
    stateController.clear();
    flatNoController.clear();
    areaController.clear();
    tehsilController.clear();
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