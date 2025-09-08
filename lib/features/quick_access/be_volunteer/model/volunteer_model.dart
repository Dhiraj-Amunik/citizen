class VolunteerModel {
  int? responseCode;
  String? message;
  Data? data;

  VolunteerModel({this.responseCode, this.message, this.data});

  VolunteerModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  String? phone;
  String? age;
  String? gender;
  String? occupation;
  String? address;
  List<String>? areasOfInterest;
  String? availability;
  String? preferredTimeSlot;
  String? hoursPerWeek;
  String? volunteerId;
  String? partyMember;
  String? mla;
  String? party;
  String? constituency;
  String? status;
  Null? approvedBy;
  bool? isActive;
  bool? isDeleted;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.name,
      this.email,
      this.phone,
      this.age,
      this.gender,
      this.occupation,
      this.address,
      this.areasOfInterest,
      this.availability,
      this.preferredTimeSlot,
      this.hoursPerWeek,
      this.volunteerId,
      this.partyMember,
      this.mla,
      this.party,
      this.constituency,
      this.status,
      this.approvedBy,
      this.isActive,
      this.isDeleted,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    age = json['age'];
    gender = json['gender'];
    occupation = json['occupation'];
    address = json['address'];
    areasOfInterest = json['areasOfInterest'].cast<String>();
    availability = json['availability'];
    preferredTimeSlot = json['preferredTimeSlot'];
    hoursPerWeek = json['hoursPerWeek'];
    volunteerId = json['volunteerId'];
    partyMember = json['partyMember'];
    mla = json['mla'];
    party = json['party'];
    constituency = json['constituency'];
    status = json['status'];
    approvedBy = json['approvedBy'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['occupation'] = this.occupation;
    data['address'] = this.address;
    data['areasOfInterest'] = this.areasOfInterest;
    data['availability'] = this.availability;
    data['preferredTimeSlot'] = this.preferredTimeSlot;
    data['hoursPerWeek'] = this.hoursPerWeek;
    data['volunteerId'] = this.volunteerId;
    data['partyMember'] = this.partyMember;
    data['mla'] = this.mla;
    data['party'] = this.party;
    data['constituency'] = this.constituency;
    data['status'] = this.status;
    data['approvedBy'] = this.approvedBy;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
