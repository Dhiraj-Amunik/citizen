import 'dart:developer';

import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_seach_place_id_modal.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/geocoding_model.dart';

class GoogleRepository extends NetworkRequester {
  final NetworkRequester _network = NetworkRequester();

  String key = dotenv.env['MAP_KEYS'] ?? "";

  Future<RepoResponse<GeoCodingSearchModal>> searchLocation({
    required String placeName,
  }) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$key";

    log(url);

    final response = await _network.get(path: url);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: GeoCodingSearchModal.fromJson(response));
  }

  Future<RepoResponse<GeocodingSeachPlaceIdModal>> getLocationByPlaceID({
    required String placeID,
  }) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$key";

    final response = await _network.get(path: url);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: GeocodingSeachPlaceIdModal.fromJson(response));
  }

  // Future<RepoResponse<MyLocationModel>> getPinCode({
  //   required double? lat,
  //   required double? lng,
  // }) async {
  //   final url =
  //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$key";
  //   final response = await _network.get(path: url);

  //   return response is APIException
  //       ? RepoResponse(error: response)
  //       : RepoResponse(data: MyLocationModel.fromJson(response));
  // }

    Future<RepoResponse<GeocodingModel>> placeFromCoordinates(
      {required double lat, required double lng}) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$key";

    log(url);

    final response = await _network.get(path: url);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: GeocodingModel.fromJson(response));
  }
}
