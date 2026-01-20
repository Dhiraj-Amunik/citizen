import 'dart:developer';

import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_seach_place_id_modal.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/geocoding_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';

class GoogleRepository extends NetworkRequester {
  final NetworkRequester _network = NetworkRequester();

  String key = dotenv.env['MAP_KEYS'] ?? "";

  /// Get language parameter for Google Maps API based on app locale
  /// Returns 'hi' if app is in Hindi, otherwise 'en'
  String _getLanguageParam() {
    try {
      final locale = GeneralStream.instance.locale;
      return locale.languageCode == 'hi' ? 'hi' : 'en';
    } catch (e) {
      return 'en'; // Fallback to English
    }
  }

  /// Build query parameters for Google Maps API with language and region
  String _buildQueryParams(String baseParams) {
    final language = _getLanguageParam();
    final params = '$baseParams&language=$language&region=in';
    return params;
  }

  Future<RepoResponse<GeoCodingSearchModal>> searchLocation({
    required String placeName,
  }) async {
    final baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$key";
    final url = _buildQueryParams(baseUrl);

    log(url);

    final response = await _network.get(path: url);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: GeoCodingSearchModal.fromJson(response));
  }

  Future<RepoResponse<GeocodingSeachPlaceIdModal>> getLocationByPlaceID({
    required String placeID,
  }) async {
    final baseUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$key";
    final url = _buildQueryParams(baseUrl);

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
    final baseUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$key";
    final url = _buildQueryParams(baseUrl);

    log(url);

    final response = await _network.get(path: url);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: GeocodingModel.fromJson(response));
  }
}
