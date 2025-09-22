import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';


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
  String? whatsapp;
  String? otp;
  String? deviceToken;
  String? dateOfBirth;
  String? fatherName;
  String? gender;
  String? city;
  String? district;
  String? state;
  String? pincode;
  String? address;
  String? avatar;
  bool? isRegistered;
  bool? isPartyMember;
  String? role;
  Constituency? parliamentryConstituency;
  Constituency? assemblyConstituency;
  bool? isAdminCreated;
  bool? isActive;
  bool? isDeleted;
  List<Document>? document;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.location,
      this.sId,
      this.name,
      this.email,
      this.phone,
      this.whatsapp,
      this.otp,
      this.deviceToken,
      this.dateOfBirth,
      this.fatherName,
      this.gender,
      this.city,
      this.district,
      this.state,
      this.pincode,
      this.address,
      this.avatar,
      this.isRegistered,
      this.isPartyMember,
      this.role,
      this.parliamentryConstituency,
      this.assemblyConstituency,
      this.isAdminCreated,
      this.isActive,
      this.isDeleted,
      this.document,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    whatsapp = json['whatsapp'];
    otp = json['otp'];
    deviceToken = json['deviceToken'];
    dateOfBirth = json['dateOfBirth'];
    fatherName = json['fatherName'];
    gender = json['gender'];
    city = json['city'];
    district = json['district'];
    state = json['state'];
    pincode = json['pincode'];
    address = json['address'];
    avatar = json['avatar'];
    isRegistered = json['isRegistered'];
    isPartyMember = json['isPartyMember'];
    role = json['role'];
    parliamentryConstituency = json['parliamentryConstituency'] != null
        ? new Constituency.fromJson(
            json['parliamentryConstituency'])
        : null;
    assemblyConstituency = json['assemblyConstituency'] != null
        ? new Constituency.fromJson(json['assemblyConstituency'])
        : null;
    isAdminCreated = json['isAdminCreated'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    if (json['document'] != null) {
      document = <Document>[];
      json['document'].forEach((v) {
        document!.add(new Document.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
    data['whatsapp'] = this.whatsapp;
    data['otp'] = this.otp;
    data['deviceToken'] = this.deviceToken;
    data['dateOfBirth'] = this.dateOfBirth;
    data['fatherName'] = this.fatherName;
    data['gender'] = this.gender;
    data['city'] = this.city;
    data['district'] = this.district;
    data['state'] = this.state;
    data['pincode'] = this.pincode;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    data['isRegistered'] = this.isRegistered;
    data['isPartyMember'] = this.isPartyMember;
    data['role'] = this.role;
    if (this.parliamentryConstituency != null) {
      data['parliamentryConstituency'] =
          this.parliamentryConstituency!.toJson();
    }
    if (this.assemblyConstituency != null) {
      data['assemblyConstituency'] = this.assemblyConstituency!.toJson();
    }
    data['isAdminCreated'] = this.isAdminCreated;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    if (this.document != null) {
      data['document'] = this.document!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
