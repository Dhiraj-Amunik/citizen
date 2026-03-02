class NotificationsModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  NotificationsModel({this.responseCode, this.message, this.data});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? userId;
  String? mlaId;
  String? adminId;
  String? module;
  String? moduleId;
  String? userType;
  dynamic appointmentId; // Can be null, String (ID), or AppointmentId object
  AppointmentId? appointmentIdObject; // Parsed appointment object
  String? type;
  String? title;
  String? message;
  String? image;
  Metadata? metadata;
  bool? read;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.userId,
    this.mlaId,
    this.adminId,
    this.appointmentId,
    this.appointmentIdObject,
    this.type,
    this.title,
    this.message,
    this.image,
    this.metadata,
    this.read,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    mlaId = json['mlaId'];
    adminId = json['adminId'];
    module = json['module'];
    moduleId = json['moduleId'];
    userType = json['userType'];
    // Handle appointmentId - can be null, String (ID), or Object (populated)
    if (json['appointmentId'] != null) {
      if (json['appointmentId'] is String) {
        appointmentId = json['appointmentId'];
        appointmentIdObject = null;
      } else if (json['appointmentId'] is Map) {
        appointmentIdObject = AppointmentId.fromJson(json['appointmentId']);
        appointmentId = appointmentIdObject?.sId;
      }
    } else {
      appointmentId = null;
      appointmentIdObject = null;
    }
    type = json['type'];
    title = json['title'];
    message = json['message'];
    image = json['image'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    read = json['read'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['mlaId'] = this.mlaId;
    data['adminId'] = this.adminId;
    data['module'] = this.module;
    data['moduleId'] = this.moduleId;
    data['userType'] = this.userType;
    data['type'] = this.type;
    data['title'] = this.title;
    data['message'] = this.message;
    data['image'] = this.image;
    if (this.appointmentIdObject != null) {
      data['appointmentId'] = this.appointmentIdObject!.toJson();
    } else if (this.appointmentId != null) {
      data['appointmentId'] = this.appointmentId;
    }
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    data['read'] = this.read;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Metadata {
  String? userName;
  String? date;
  String? timeSlot;
  String? rescheduledDate;

  Metadata({this.userName, this.date, this.timeSlot, this.rescheduledDate});

  Metadata.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    date = json['date'];
    timeSlot = json['timeSlot'];
    rescheduledDate = json['rescheduledDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['date'] = this.date;
    data['timeSlot'] = this.timeSlot;
    data['rescheduledDate'] = this.rescheduledDate;
    return data;
  }
}

class AppointmentId {
  String? sId;
  String? date;
  String? rescheduledDate;
  String? timeSlot;
  String? status;

  AppointmentId({
    this.sId,
    this.date,
    this.rescheduledDate,
    this.timeSlot,
    this.status,
  });

  AppointmentId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    date = json['date'];
    rescheduledDate =
        json['resheduledDate'] ??
        json['rescheduledDate'] ??
        json['reScheduledDate'];
    timeSlot = json['timeSlot'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['date'] = this.date;
    data['rescheduledDate'] = this.rescheduledDate;
    data['timeSlot'] = this.timeSlot;
    data['status'] = this.status;
    return data;
  }
}
