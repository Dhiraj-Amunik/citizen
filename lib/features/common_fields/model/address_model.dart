import 'package:inldsevak/features/common_fields/model/pincode_model.dart';

class AddressModel {
   String formattedAddress;
   String city;
   String district;
   String state;
   String pincode;
   double latitude;
   double longitude;

  AddressModel({
    required this.formattedAddress,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  factory AddressModel.fromPinCodeModel(PinCodeModel model) {
    // Use the first result as it's the most specific
    final firstResult = model.results!.first;

    String city = '';
    String district = '';
    String state = '';
    String pincode = '';

    // Extract address components
    for (var component in firstResult.addressComponents!) {
      final types = component.types ?? [];

      if (types.contains('locality')) {
        city = component.longName ?? '';
      } else if (types.contains('administrative_area_level_3') ||
          types.contains('administrative_area_level_2')) {
        district = component.longName ?? '';
      } else if (types.contains('administrative_area_level_1')) {
        state = component.longName ?? component.shortName ?? '';
      } else if (types.contains('postal_code')) {
        pincode = component.longName ?? '';
      }
    }

    // If we didn't find certain components in the first result,
    // look for them in other results
    if (city.isEmpty || district.isEmpty || state.isEmpty || pincode.isEmpty) {
      for (var result in model.results!) {
        for (var component in result.addressComponents!) {
          final types = component.types ?? [];

          if (city.isEmpty && types.contains('locality')) {
            city = component.longName ?? '';
          } else if (district.isEmpty &&
              (types.contains('administrative_area_level_3') ||
                  types.contains('administrative_area_level_2'))) {
            district = component.longName ?? '';
          } else if (state.isEmpty &&
              types.contains('administrative_area_level_1')) {
            state = component.shortName ?? component.longName ?? '';
          } else if (pincode.isEmpty && types.contains('postal_code')) {
            pincode = component.longName ?? '';
          }
        }
      }
    }

    return AddressModel(
      formattedAddress: firstResult.formattedAddress ?? '',
      city: city,
      district: district,
      state: state,
      pincode: pincode,
      latitude: firstResult.geometry?.location?.latitude ?? 0.0,
      longitude: firstResult.geometry?.location?.longitude ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'formatted_address': formattedAddress,
      'city': city,
      'district': district,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
