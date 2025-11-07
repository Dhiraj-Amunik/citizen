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
  String? constituency;
  bool? isAdminCreated;
  Location? location;
  bool? isActive;
  List<Document>? document;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? area;
  String? city;
  List<DeviceTokens>? deviceTokens;
  String? district;
  String? fatherName;
  String? flatNumber;
  bool? isDeleted;
  String? pincode;
  String? state;
  String? teshil;
  String? whatsapp;
  String? membershipId;
  Constituency? parliamentryConstituency;
  Constituency? assemblyConstituency;
  int? unReadNotificationsCount;
  Data({
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
    this.location,
    this.isActive,
    this.document,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.area,
    this.city,
    this.deviceTokens,
    this.district,
    this.fatherName,
    this.flatNumber,
    this.isDeleted,
    this.pincode,
    this.state,
    this.teshil,
    this.whatsapp,
    this.assemblyConstituency,
    this.parliamentryConstituency,
    this.unReadNotificationsCount,
    this.membershipId,
  });

  Data.fromJson(Map<String, dynamic> json) {
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
    constituency = json['constituency'];
    isAdminCreated = json['isAdminCreated'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
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
    area = json['area'];
    city = json['city'];
    if (json['deviceTokens'] != null) {
      deviceTokens = <DeviceTokens>[];
      json['deviceTokens'].forEach((v) {
        deviceTokens!.add(new DeviceTokens.fromJson(v));
      });
    }
    district = json['district'];
    fatherName = json['fatherName'];
    flatNumber = json['flatNumber'];
    isDeleted = json['isDeleted'];
    pincode = json['pincode'];
    state = json['state'];
    teshil = json['teshil'];
    whatsapp = json['whatsapp'];
    membershipId = json['memberShipId'];
    unReadNotificationsCount = json['unReadNotificationsCount'];

    parliamentryConstituency = json['parliamentryConstituency'] != null
        ? new Constituency.fromJson(json['parliamentryConstituency'])
        : null;
    assemblyConstituency = json['assemblyConstituency'] != null
        ? new Constituency.fromJson(json['assemblyConstituency'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['constituency'] = this.constituency;
    data['isAdminCreated'] = this.isAdminCreated;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['isActive'] = this.isActive;
    if (this.document != null) {
      data['document'] = this.document!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['area'] = this.area;
    data['city'] = this.city;
    if (this.deviceTokens != null) {
      data['deviceTokens'] = this.deviceTokens!.map((v) => v.toJson()).toList();
    }
    data['district'] = this.district;
    data['fatherName'] = this.fatherName;
    data['flatNumber'] = this.flatNumber;
    data['isDeleted'] = this.isDeleted;
    data['pincode'] = this.pincode;
    data['state'] = this.state;
    data['teshil'] = this.teshil;
    data['whatsapp'] = this.whatsapp;
    data['memberShipId'] = this.membershipId;
    if (this.parliamentryConstituency != null) {
      data['parliamentryConstituency'] = this.parliamentryConstituency!
          .toJson();
    }
    if (this.assemblyConstituency != null) {
      data['assemblyConstituency'] = this.assemblyConstituency!.toJson();
    }
    data['unReadNotificationsCount'] = this.unReadNotificationsCount;
    return data;
  }
}

class DeviceTokens {
  String? uuid;
  String? deviceType;
  String? deviceToken;
  String? createdAt;
  String? sId;

  DeviceTokens({
    this.uuid,
    this.deviceType,
    this.deviceToken,
    this.createdAt,
    this.sId,
  });

  DeviceTokens.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    deviceType = json['deviceType'];
    deviceToken = json['deviceToken'];
    createdAt = json['createdAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['deviceType'] = this.deviceType;
    data['deviceToken'] = this.deviceToken;
    data['createdAt'] = this.createdAt;
    data['_id'] = this.sId;
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

  Document({
    this.documentType,
    this.documentUrl,
    this.documentNumber,
    this.sId,
  });

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
