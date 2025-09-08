class AppointmentModel {
  int? responseCode;
  String? message;
  Data? data;

  AppointmentModel({this.responseCode, this.message, this.data});

  AppointmentModel.fromJson(Map<String, dynamic> json) {
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
  String? phone;
  String? memberShipId;
  bool? isPartyMember;
  String? date;
  String? timeSlot;
  String? purpose;
  String? reason;
  String? user;
  String? mla;
  String? partyMember;
  String? priority;
  String? status;
  String? approvedBy;
  bool? isActive;
  bool? isDeleted;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.name,
      this.phone,
      this.memberShipId,
      this.isPartyMember,
      this.date,
      this.timeSlot,
      this.purpose,
      this.reason,
      this.user,
      this.mla,
      this.partyMember,
      this.priority,
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
    phone = json['phone'];
    memberShipId = json['memberShipId'];
    isPartyMember = json['isPartyMember'];
    date = json['date'];
    timeSlot = json['timeSlot'];
    purpose = json['purpose'];
    reason = json['reason'];
    user = json['user'];
    mla = json['mla'];
    partyMember = json['partyMember'];
    priority = json['priority'];
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
    data['phone'] = this.phone;
    data['memberShipId'] = this.memberShipId;
    data['isPartyMember'] = this.isPartyMember;
    data['date'] = this.date;
    data['timeSlot'] = this.timeSlot;
    data['purpose'] = this.purpose;
    data['reason'] = this.reason;
    data['user'] = this.user;
    data['mla'] = this.mla;
    data['partyMember'] = this.partyMember;
    data['priority'] = this.priority;
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
