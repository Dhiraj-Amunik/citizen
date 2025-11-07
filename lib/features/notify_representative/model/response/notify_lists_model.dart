class NotifyListModel {
  int? responseCode;
  String? message;
  Data? data;

  NotifyListModel({this.responseCode, this.message, this.data});

  NotifyListModel.fromJson(Map<String, dynamic> json) {
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
  int? totalNotifyRepresentative;
  int? page;
  int? pageSize;
  List<NotifyRepresentative>? notifyRepresentative;

  Data(
      {this.totalNotifyRepresentative,
      this.page,
      this.pageSize,
      this.notifyRepresentative});

  Data.fromJson(Map<String, dynamic> json) {
    totalNotifyRepresentative = json['totalNotifyRepresentative'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['notifyRepresentative'] != null) {
      notifyRepresentative = <NotifyRepresentative>[];
      json['notifyRepresentative'].forEach((v) {
        notifyRepresentative!.add(new NotifyRepresentative.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalNotifyRepresentative'] = this.totalNotifyRepresentative;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.notifyRepresentative != null) {
      data['notifyRepresentative'] =
          this.notifyRepresentative!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotifyRepresentative {
  String? location;
  String? sId;
  String? title;
  String? eventType;
  String? description;
  String? dateAndTime;
  List<String>? documents;
  List<String>? specialInvites;
  bool? isActive;
  bool? isDeleted;
  List<String>? responses;
  String? createdAt;
  String? updatedAt;
  int? iV;
  PartyMember? partyMember;

  NotifyRepresentative(
      {this.location,
      this.sId,
      this.title,
      this.eventType,
      this.description,
      this.dateAndTime,
      this.documents,
      this.specialInvites,
      this.isActive,
      this.isDeleted,
      this.responses,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.partyMember});

  NotifyRepresentative.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    sId = json['_id'];
    title = json['title'];
    eventType = json['eventType'];
    description = json['description'];
    dateAndTime = json['dateAndTime'];
    documents = json['documents'].cast<String>();
    specialInvites = json['specialInvites'].cast<String>();
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    responses = json['responses'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    partyMember = json['partyMember'] != null
        ? new PartyMember.fromJson(json['partyMember'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['location'] = this.location;
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['eventType'] = this.eventType;
    data['description'] = this.description;
    data['dateAndTime'] = this.dateAndTime;
    data['documents'] = this.documents;
    data['specialInvites'] = this.specialInvites;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['responses'] = this.responses;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.partyMember != null) {
      data['partyMember'] = this.partyMember!.toJson();
    }
    return data;
  }
}

class PartyMember {
  String? sId;
  User? user;

  PartyMember({this.sId, this.user});

  PartyMember.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? avatar;

  User({this.sId, this.name, this.email, this.phone, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['avatar'] = this.avatar;
    return data;
  }
}
