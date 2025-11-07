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
  int? totalAppointments;
  int? page;
  int? pageSize;
  List<Appointments>? appointments;

  Data({this.totalAppointments, this.page, this.pageSize, this.appointments});

  Data.fromJson(Map<String, dynamic> json) {
    totalAppointments = json['totalAppointments'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['appointments'] != null) {
      appointments = <Appointments>[];
      json['appointments'].forEach((v) {
        appointments!.add(new Appointments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalAppointments'] = this.totalAppointments;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.appointments != null) {
      data['appointments'] = this.appointments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Appointments {
  String? sId;
  String? mla;
  String? bookFor;
  String? name;
  String? memberShipId;
  String? phone;
  String? date;
  String? timeSlot;
  String? purpose;
  String? reason;
  List<String>? documents;
  String? user;
  String? partyMember;
  String? priority;
  bool? isPartyMember;
  String? status;
  String? approvedBy;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Appointments(
      {this.sId,
      this.mla,
      this.bookFor,
      this.name,
      this.memberShipId,
      this.phone,
      this.date,
      this.timeSlot,
      this.purpose,
      this.reason,
      this.documents,
      this.user,
      this.partyMember,
      this.priority,
      this.isPartyMember,
      this.status,
      this.approvedBy,
      this.isActive,
      this.isDeleted,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Appointments.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mla = json['mla'];
    bookFor = json['bookFor'];
    name = json['name'];
    memberShipId = json['memberShipId'];
    phone = json['phone'];
    date = json['date'];
    timeSlot = json['timeSlot'];
    purpose = json['purpose'];
    reason = json['reason'];
    documents = json['documents'].cast<String>();
    user = json['user'];
    partyMember = json['partyMember'];
    priority = json['priority'];
    isPartyMember = json['isPartyMember'];
    status = json['status'];
    approvedBy = json['approvedBy'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['mla'] = this.mla;
    data['bookFor'] = this.bookFor;
    data['name'] = this.name;
    data['memberShipId'] = this.memberShipId;
    data['phone'] = this.phone;
    data['date'] = this.date;
    data['timeSlot'] = this.timeSlot;
    data['purpose'] = this.purpose;
    data['reason'] = this.reason;
    data['documents'] = this.documents;
    data['user'] = this.user;
    data['partyMember'] = this.partyMember;
    data['priority'] = this.priority;
    data['isPartyMember'] = this.isPartyMember;
    data['status'] = this.status;
    data['approvedBy'] = this.approvedBy;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
