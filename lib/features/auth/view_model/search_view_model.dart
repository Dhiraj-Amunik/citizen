import 'package:flutter/material.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/auth/services/search_repository.dart';

class SearchViewModel extends ChangeNotifier {
  //

  List<Predictions> searchplaces = [];

  LatLng? latlong;

  Future<List<Predictions>> getSearchPlaces(String placeName) async {
    searchplaces.clear();
    try {
      final response = await SearchRepository().searchLocation(
        placeName: placeName,
      );
      if (response.data?.status == "OK") {
        searchplaces.addAll(List.from(response.data?.predictions as List));
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
      final response = await SearchRepository().getLocationByPlaceID(
        placeID: placeID,
      );
      if (response.data?.status == "OK") {
        latlong = LatLng(
          latitude: response.data?.result?.geometry?.location?.lat ?? 0.0,
          longitude: response.data?.result?.geometry?.location?.lng ?? 0.0,
        );
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});
}
