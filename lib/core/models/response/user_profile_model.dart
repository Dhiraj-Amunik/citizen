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
  String? avatar;
  bool? isRegistered;
  bool? isPartyMember;
  bool? isActive;
  List<Document>? document;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? address;
  Constituency? constituency;
  String? maritalStatus;
  String? parentName;
  String? preferredRole;
  bool? isAdminCreated;
  String? role;

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
      this.avatar,
      this.isRegistered,
      this.isPartyMember,
      this.isActive,
      this.document,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.address,
      this.constituency,
      this.maritalStatus,
      this.parentName,
      this.preferredRole,
      this.isAdminCreated,
      this.role});

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
    avatar = json['avatar'];
    isRegistered = json['isRegistered'];
    isPartyMember = json['isPartyMember'];
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
    address = json['address'];
    constituency = json['constituency'] != null
        ? new Constituency.fromJson(json['constituency'])
        : null;
    maritalStatus = json['maritalStatus'];
    parentName = json['parentName'];
    preferredRole = json['preferredRole'];
    isAdminCreated = json['isAdminCreated'];
    role = json['role'];
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
    data['avatar'] = this.avatar;
    data['isRegistered'] = this.isRegistered;
    data['isPartyMember'] = this.isPartyMember;
    data['isActive'] = this.isActive;
    if (this.document != null) {
      data['document'] = this.document!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['address'] = this.address;
    if (this.constituency != null) {
      data['constituency'] = this.constituency!.toJson();
    }
    data['maritalStatus'] = this.maritalStatus;
    data['parentName'] = this.parentName;
    data['preferredRole'] = this.preferredRole;
    data['isAdminCreated'] = this.isAdminCreated;
    data['role'] = this.role;
    return data;
  }
}

class Location {
  String? type;
  List<int>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
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
