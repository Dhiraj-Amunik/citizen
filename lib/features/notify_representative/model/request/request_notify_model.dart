class RequestNotifytModel {
  String title;
  String? location;
  String? eventDate;
  String eventTime;
  String description;
  String? id;
  List<String> documents;
  String? mlaId;
  LocationCoordinates? locationCoordinates;
  String? district;
  String? mandal;
  String? village;
  String? street;
  String? pincode;
  String? area;
  String? state;
  String? assemblyConstituency;
  String? parliamentaryConstituency;

  RequestNotifytModel({
    required this.title,
    this.location,
    required this.eventDate,
    this.eventTime = "00:00",
    required this.description,
    required this.documents,
    this.id = "",
    this.mlaId,
    this.locationCoordinates,
    this.district,
    this.mandal,
    this.village,
    this.street,
    this.pincode,
    this.area,
    this.state,
    this.assemblyConstituency,
    this.parliamentaryConstituency,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'date': eventDate,
      'time': eventTime,
      'description': description,
      'documents': documents,
      "notifyRepresentativeId": id,
    };

    if (mlaId != null && mlaId!.isNotEmpty) {
      data['mlaId'] = mlaId;
    }

    // Location must always be an object with lat and lng
    if (locationCoordinates != null) {
      data['location'] = {
        'lat': locationCoordinates!.lat,
        'lng': locationCoordinates!.lng,
      };
    }

    // Always include address fields, even if empty
    data['district'] = district ?? "";
    data['mandal'] = mandal ?? "";
    data['village'] = village ?? "";
    data['street'] = street ?? "";
    data['pincode'] = pincode ?? "";
    data['area'] = area ?? "";
    data['state'] = state ?? "";
    
    if (assemblyConstituency != null && assemblyConstituency!.isNotEmpty) {
      data['assemblyConstituency'] = assemblyConstituency;
    }
    
    if (parliamentaryConstituency != null && parliamentaryConstituency!.isNotEmpty) {
      data['parliamentaryConstituency'] = parliamentaryConstituency;
    }

    return data;
  }
}

class LocationCoordinates {
  final double lat;
  final double lng;

  LocationCoordinates({
    required this.lat,
    required this.lng,
  });
}
