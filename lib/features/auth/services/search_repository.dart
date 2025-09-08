import 'dart:developer';

import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_seach_place_id_modal.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';

class SearchRepository extends NetworkRequester {
  final NetworkRequester _network = NetworkRequester();

  String key = "AIzaSyDjhRfuZD95rSJSqXRhuxvELmmO1lFLV-k";

  Future<RepoResponse<GeoCodingSerachModal>> searchLocation({
    required String placeName,
  }) async {
    final url =
        "";

    log(url);

    final response = await _network.get(path: url);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: GeoCodingSerachModal.fromJson(response));
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
}
