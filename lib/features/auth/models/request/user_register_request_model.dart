class RequestRegisterModel {
  String? name;
  String? email;
  String? dateOfBirth;
  String? gender;
  String? address;
  String? avatar;
  String? constituencyId;
  Location? location;
  List<Document>? document;

  RequestRegisterModel({
    this.name,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.avatar,
    this.constituencyId,
    this.location,
    this.document,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'avatar': avatar,
      'constituencyId': constituencyId,
      'location': location?.toJson(),
      'document': document?.map((doc) => doc.toJson()).toList(),
    };
  }
}

class Location {
  final String type = 'Point'; // Static type
  List<double?> coordinates;

  Location({required this.coordinates});

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}

class Document {
  final String documentType = 'aadhaar'; // Static document type
  String documentUrl;
  String documentNumber;

  Document({required this.documentUrl, required this.documentNumber});

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentUrl': documentUrl,
      'documentNumber': documentNumber,
    };
  }
}
