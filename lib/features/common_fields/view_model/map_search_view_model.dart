import 'package:flutter/material.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/services/search_repository.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:provider/provider.dart';

class MapSearchViewModel extends ChangeNotifier with TransparentCircular {
  //
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  List<Predictions> searchplaces = [];

  AddressModel? addressModel;

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
                      .getConstituenciesWithPincode(
                        pincode: pincodeController.text,
                      );
                  notifyListeners();
                  return;
                }
              }
            }
          }
        }
      }
      return CommonSnackbar(text: "No Address Found").showToast();
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
