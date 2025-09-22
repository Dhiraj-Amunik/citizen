import 'package:flutter/material.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/services/search_repository.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:geolocator/geolocator.dart';

class MapSearchViewModel extends ChangeNotifier
    with TransparentCircular, CupertinoDialogMixin {
  Position? currentPosition;

  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  List<Predictions> searchplaces = [];

  AddressModel? addressModel;

  getCurrentLocation() async {
    await checkPermission();
    currentPosition = await Geolocator.getCurrentPosition();
    notifyListeners();
  }

  checkPermission() async {
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

    if (currentPosition != null) {
      getLoactionByCoordinates();
    }
  }

  Future<List<Predictions>> getSearchPlaces(String placeName) async {
    searchplaces.clear();
    clear();
    try {
      final response = await SearchRepository().searchLocation(
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

  Future<void> getLoactionByCoordinates() async {
    try {
      showCustomDialogTransperent(isShowing: true);

      final latitude = currentPosition?.latitude;
      final longitude = currentPosition?.longitude;
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

  clear() {
    addressModel = null;
    searchplaces.clear();
    cityController.clear();
    districtController.clear();
    stateController.clear();
    pincodeController.clear();
  }

  loadAddress({AddressModel? model}) {
    pincodeController.text = model?.pincode ?? "";
    stateController.text = model?.state ?? "";
    districtController.text = model?.district ?? "";
    cityController.text = model?.city ?? "";
    addressModel?.latitude = model?.latitude ?? 0.0;
    addressModel?.longitude = model?.longitude ?? 0.0;
  }
}


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