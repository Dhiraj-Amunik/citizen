
import 'package:inldsevak/features/common_fields/model/geocoding_model.dart';

class AddressModel {
  final String? formattedAddress;
  final String? houseNo;
  final String? flatNo;
  final String? area;
  final String? subLocality;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? tehsil;
  final String? district;
  final String? placeId;
  final double? latitude;
  final double? longitude;

  AddressModel({
    this.formattedAddress,
    this.houseNo,
    this.flatNo,
    this.area,
    this.subLocality,
    this.city,
    this.state,
    this.postalCode,
    this.tehsil,
    this.district,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromGeocodingModel(GeocodingModel model) {
    if (model.results == null || model.results!.isEmpty) {
      return AddressModel();
    }

    // Use the first result as it's the most specific
    final firstResult = model.results!.first;

    String? houseNo;
    String? flatNo;
    String? area;
    String? subLocality;
    String? city;
    String? state;
    String? postalCode;
    String? tehsil;
    String? district;

    // Extract address components from first result
    for (var component in firstResult.addressComponents!) {
      final types = component.types ?? [];
      
      if (types.contains('premise') || types.contains('subpremise')) {
        houseNo = component.longName ?? component.shortName;
      } else if (types.contains('street_number')) {
        flatNo = component.longName ?? component.shortName;
      } else if (types.contains('sublocality_level_2') || 
                 types.contains('neighborhood')) {
        area = component.longName ?? component.shortName;
      } else if (types.contains('sublocality_level_1') || 
                 types.contains('sublocality')) {
        subLocality = component.longName ?? component.shortName;
      } else if (types.contains('locality')) {
        city = component.longName ?? component.shortName;
      } else if (types.contains('administrative_area_level_3')) {
        tehsil = component.longName ?? component.shortName;
      } else if (types.contains('administrative_area_level_2')) {
        district = component.longName ?? component.shortName;
      } else if (types.contains('administrative_area_level_1')) {
        state = component.longName ?? component.shortName;
      } else if (types.contains('postal_code')) {
        postalCode = component.longName ?? component.shortName;
      }
    }

    return AddressModel(
      formattedAddress: firstResult.formattedAddress,
      houseNo: houseNo,
      flatNo: flatNo,
      area: area,
      subLocality: subLocality,
      city: city,
      state: state,
      postalCode: postalCode,
      tehsil: tehsil,
      district: district,
      placeId: firstResult.placeId,
      latitude: firstResult.geometry?.location?.lat,
      longitude: firstResult.geometry?.location?.lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatted_address': formattedAddress,
      'house_no': houseNo,
      'flat_no': flatNo,
      'area': area,
      'sub_locality': subLocality,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'tehsil': tehsil,
      'district': district,
      'place_id': placeId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper method to check if address has basic validity
  bool get isValid {
    return city != null && state != null && postalCode != null;
  }

  // Get a short address representation (handles null values)
  String get shortAddress {
    final parts = [houseNo, area, city].where((part) => part != null && part!.isNotEmpty).toList();
    return parts.join(', ');
  }

  // Get full address without formatted address (handles null values)
  String get readableAddress {
    final parts = [
      if (houseNo != null && houseNo!.isNotEmpty) 'House: $houseNo',
      if (flatNo != null && flatNo!.isNotEmpty) 'Flat: $flatNo',
      area,
      subLocality,
      city,
      if (district != null && district!.isNotEmpty) 'Dist: $district',
      if (tehsil != null && tehsil!.isNotEmpty) 'Tehsil: $tehsil',
      state,
      postalCode,
    ].where((part) => part != null && part.isNotEmpty).toList();
    
    return parts.join(', ');
  }

  // Safe getters that return empty string if null
  String get safeFormattedAddress => formattedAddress ?? '';
  String get safeHouseNo => houseNo ?? '';
  String get safeFlatNo => flatNo ?? '';
  String get safeArea => area ?? '';
  String get safeSubLocality => subLocality ?? '';
  String get safeCity => city ?? '';
  String get safeState => state ?? '';
  String get safePostalCode => postalCode ?? '';
  String get safeTehsil => tehsil ?? '';
  String get safeDistrict => district ?? '';
  String get safePlaceId => placeId ?? '';
  double get safeLatitude => latitude ?? 0.0;
  double get safeLongitude => longitude ?? 0.0;

  @override
  String toString() {
    return 'AddressModel(\n'
           '  formattedAddress: $formattedAddress,\n'
           '  houseNo: $houseNo,\n'
           '  flatNo: $flatNo,\n'
           '  area: $area,\n'
           '  subLocality: $subLocality,\n'
           '  city: $city,\n'
           '  state: $state,\n'
           '  postalCode: $postalCode,\n'
           '  tehsil: $tehsil,\n'
           '  district: $district,\n'
           '  placeId: $placeId,\n'
           '  latitude: $latitude,\n'
           '  longitude: $longitude\n'
           ')';
  }

  // Copy with method for easy updates
  AddressModel copyWith({
    String? formattedAddress,
    String? houseNo,
    String? flatNo,
    String? area,
    String? subLocality,
    String? city,
    String? state,
    String? postalCode,
    String? tehsil,
    String? district,
    String? placeId,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      formattedAddress: formattedAddress ?? this.formattedAddress,
      houseNo: houseNo ?? this.houseNo,
      flatNo: flatNo ?? this.flatNo,
      area: area ?? this.area,
      subLocality: subLocality ?? this.subLocality,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      tehsil: tehsil ?? this.tehsil,
      district: district ?? this.district,
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}