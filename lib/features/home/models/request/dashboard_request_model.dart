class DashboardRequestModel {
  final double? longitude;
  final double? latitude;

  DashboardRequestModel({
    this.longitude,
    this.latitude,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // Coordinates format: [latitude, longitude] - matches GeoJSON and API response format
      'coordinates': latitude != null && longitude != null
          ? [latitude, longitude]
          : [],
    };
    return data;
  }
}

