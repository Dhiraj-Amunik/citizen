class MyCurrentLocationRequestModel {
  final double? longitude;
  final double? latitude;
  final int? page;
  final int? pageSize;

  MyCurrentLocationRequestModel({
    this.longitude,
    this.latitude,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'coordinates': [longitude, latitude],
      'page': page,
      'pageSize': pageSize,
    };
  }
}
