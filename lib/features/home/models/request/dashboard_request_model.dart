class DashboardRequestModel {
  final double? longitude;
  final double? latitude;

  DashboardRequestModel({
    this.longitude,
    this.latitude,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // Coordinates format: [longitude, latitude]
      'coordinates': longitude != null && latitude != null
          ? [longitude, latitude]
          : [],
    };
    return data;
  }
}

