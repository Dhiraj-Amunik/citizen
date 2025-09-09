class EventsModel {
  int? responseCode;
  String? message;
  Data? data;

  EventsModel({this.responseCode, this.message, this.data});

  EventsModel.fromJson(Map<String, dynamic> json) {
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
  int? totalEvents;
  int? page;
  int? pageSize;
  List<Events>? events;

  Data({this.totalEvents, this.page, this.pageSize, this.events});

  Data.fromJson(Map<String, dynamic> json) {
    totalEvents = json['totalEvents'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        events!.add(new Events.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalEvents'] = this.totalEvents;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.events != null) {
      data['events'] = this.events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Events {
  String? sId;
  String? title;
  String? eventType;
  String? description;
  String? dateAndTime;
  String? location;
  String? poster;
  Mla? mla;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Events({
    this.sId,
    this.title,
    this.eventType,
    this.description,
    this.dateAndTime,
    this.location,
    this.poster,
    this.mla,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Events.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    eventType = json['eventType'];
    description = json['description'];
    dateAndTime = json['dateAndTime'];
    location = json['location'];
    poster = json['poster'];
    mla = json['mla'] != null ? new Mla.fromJson(json['mla']) : null;
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['eventType'] = this.eventType;
    data['description'] = this.description;
    data['dateAndTime'] = this.dateAndTime;
    data['location'] = this.location;
    data['poster'] = this.poster;
    if (this.mla != null) {
      data['mla'] = this.mla!.toJson();
    }
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Mla {
  String? sId;
  User? user;

  Mla({this.sId, this.user});

  Mla.fromJson(Map<String, dynamic> json) {
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
