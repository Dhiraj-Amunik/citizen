class UserProfileModel {
  int? responseCode;
  String? message;
  Data? data;

  UserProfileModel({this.responseCode, this.message, this.data});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Location? location;
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? otp;
  String? deviceToken;
  String? dateOfBirth;
  String? gender;
  String? address;
  String? avatar;
  bool? isRegistered;
  bool? isPartyMember;
  String? role;
  Constituency? constituency;
  bool? isAdminCreated;
  bool? isActive;
  List<Document>? document;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? city;
  String? district;
  String? pincode;
  String? state;
  String? whatsapp;
  String? fatherName;
  bool? isDeleted;

  Data(
      {this.location,
      this.sId,
      this.name,
      this.email,
      this.phone,
      this.otp,
      this.deviceToken,
      this.dateOfBirth,
      this.gender,
      this.address,
      this.avatar,
      this.isRegistered,
      this.isPartyMember,
      this.role,
      this.constituency,
      this.isAdminCreated,
      this.isActive,
      this.document,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.city,
      this.district,
      this.pincode,
      this.state,
      this.whatsapp,
      this.fatherName,
      this.isDeleted});

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    otp = json['otp'];
    deviceToken = json['deviceToken'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    address = json['address'];
    avatar = json['avatar'];
    isRegistered = json['isRegistered'];
    isPartyMember = json['isPartyMember'];
    role = json['role'];
    constituency = json['constituency'] != null
        ? new Constituency.fromJson(json['constituency'])
        : null;
    isAdminCreated = json['isAdminCreated'];
    isActive = json['isActive'];
    if (json['document'] != null) {
      document = <Document>[];
      json['document'].forEach((v) {
        document!.add(new Document.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    city = json['city'];
    district = json['district'];
    pincode = json['pincode'];
    state = json['state'];
    whatsapp = json['whatsapp'];
    fatherName = json['fatherName'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['otp'] = this.otp;
    data['deviceToken'] = this.deviceToken;
    data['dateOfBirth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    data['isRegistered'] = this.isRegistered;
    data['isPartyMember'] = this.isPartyMember;
    data['role'] = this.role;
    if (this.constituency != null) {
      data['constituency'] = this.constituency!.toJson();
    }
    data['isAdminCreated'] = this.isAdminCreated;
    data['isActive'] = this.isActive;
    if (this.document != null) {
      data['document'] = this.document!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['city'] = this.city;
    data['district'] = this.district;
    data['pincode'] = this.pincode;
    data['state'] = this.state;
    data['whatsapp'] = this.whatsapp;
    data['fatherName'] = this.fatherName;
    data['isDeleted'] = this.isDeleted;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class Constituency {
  String? sId;
  String? name;
  String? area;

  Constituency({this.sId, this.name, this.area});

  Constituency.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    area = json['area'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['area'] = this.area;
    return data;
  }
}

class Document {
  String? documentType;
  String? documentUrl;
  String? documentNumber;
  String? sId;

  Document(
      {this.documentType, this.documentUrl, this.documentNumber, this.sId});

  Document.fromJson(Map<String, dynamic> json) {
    documentType = json['documentType'];
    documentUrl = json['documentUrl'];
    documentNumber = json['documentNumber'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['documentType'] = this.documentType;
    data['documentUrl'] = this.documentUrl;
    data['documentNumber'] = this.documentNumber;
    data['_id'] = this.sId;
    return data;
  }
}
