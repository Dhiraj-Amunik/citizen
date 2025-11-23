class MyCurrentLocationRequestModel {
  final double? longitude;
  final double? latitude;
  final int? page;
  final int? pageSize;
  final int? radius;

  MyCurrentLocationRequestModel({
    this.longitude,
    this.latitude,
    this.page,
    this.pageSize,
    this.radius,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'page': page,
      'pageSize': pageSize,
    };
    
    // New format: coordinates as [latitude, longitude] array
    if (latitude != null && longitude != null) {
      data['coordinates'] = [latitude, longitude];
    }
    
    if (radius != null) {
      data['radius'] = radius;
    }
    
    return data;
  }
}
