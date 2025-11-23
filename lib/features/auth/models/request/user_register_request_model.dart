class RequestRegisterModel {
  String? name;
  String? fatherName;
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
  String? parliamentaryId;
  String? assemblyId;
  Location? location;
  List<Document>? document;
  String? area;
  String? flatNo;
  String? tehsil;
  String? invitedBy;

  RequestRegisterModel({
    this.name,
    this.fatherName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.avatar,
    this.parliamentaryId,
    this.assemblyId,
    this.location,
    this.document,
    this.whatsappNo,
    this.state,
    this.city,
    this.district,
    this.pincode,
    this.area,
    this.flatNo,
    this.tehsil,
    this.invitedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fatherName': fatherName,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender?.toLowerCase(),
      'address': "",
      'avatar': avatar,
      'parliamentryConstituencyId': parliamentaryId,
      'assemblyConstituencyId': assemblyId,
      "city": city,
      "state": state,
      "district": district,
      "pincode": pincode,
      "whatsapp": whatsappNo,
      'location': location?.toJson(),
      'document': document?.map((doc) => doc.toJson()).toList(),
      "area": area,
      "flatNumber": flatNo,
      "teshil": tehsil,
      "invitedBy": invitedBy ?? "",
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

  Document({
    required this.documentUrl,
    required this.documentNumber,
    required this.documentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentUrl': documentUrl,
      'documentNumber': documentNumber,
    };
  }
}
