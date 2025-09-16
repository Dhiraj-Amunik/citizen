class RequestRegisterModel {
  String? name;
  String? email;
  String? whatsappNo;
  String? dateOfBirth;
  String? gender;
  String? address;
  String? city;
  String? state;
  String? district;
  String? pincode;
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
    this.whatsappNo,
    this.state,
    this.city,
    this.district,
    this.pincode,
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
      "city": city,
      "state": state,
      "district": district,
      "pincode": pincode,
      "whatsapp": whatsappNo,
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
  String documentType; // Static document type
  String documentUrl;
  String documentNumber;

  Document({required this.documentUrl, required this.documentNumber,required this.documentType});

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentUrl': documentUrl,
      'documentNumber': documentNumber,
    };
  }
}
