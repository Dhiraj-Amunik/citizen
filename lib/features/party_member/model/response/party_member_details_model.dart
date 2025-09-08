class PartyMemberDetailsModel {
  int? responseCode;
  String? message;
  Data? data;

  PartyMemberDetailsModel({this.responseCode, this.message, this.data});

  PartyMemberDetailsModel.fromJson(Map<String, dynamic> json) {
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
  User? user;
  PartyMemberDetails? partyMemberDetails;

  Data({this.user, this.partyMemberDetails});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    partyMemberDetails = json['partyMemberDetails'] != null
        ? new PartyMemberDetails.fromJson(json['partyMemberDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.partyMemberDetails != null) {
      data['partyMemberDetails'] = this.partyMemberDetails!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? dateOfBirth;
  String? gender;
  String? address;
  String? avatar;
  bool? isRegistered;
  bool? isPartyMember;
  String? parentName;
  String? maritalStatus;
  String? constituency;
  String? preferredRole;
  String? createdBy;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  User(
      {this.sId,
      this.name,
      this.email,
      this.phone,
      this.dateOfBirth,
      this.gender,
      this.address,
      this.avatar,
      this.isRegistered,
      this.isPartyMember,
      this.parentName,
      this.maritalStatus,
      this.constituency,
      this.preferredRole,
      this.createdBy,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.iV});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    address = json['address'];
    avatar = json['avatar'];
    isRegistered = json['isRegistered'];
    isPartyMember = json['isPartyMember'];
    parentName = json['parentName'];
    maritalStatus = json['maritalStatus'];
    constituency = json['constituency'];
    preferredRole = json['preferredRole'];
    createdBy = json['createdBy'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['dateOfBirth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    data['isRegistered'] = this.isRegistered;
    data['isPartyMember'] = this.isPartyMember;
    data['parentName'] = this.parentName;
    data['maritalStatus'] = this.maritalStatus;
    data['constituency'] = this.constituency;
    data['preferredRole'] = this.preferredRole;
    data['createdBy'] = this.createdBy;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class PartyMemberDetails {
  String? sId;
  String? status;

  PartyMemberDetails({this.sId, this.status});

  PartyMemberDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['status'] = this.status;
    return data;
  }
}
