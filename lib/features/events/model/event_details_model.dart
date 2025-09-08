class EventDetailsModel {
  int? responseCode;
  String? message;
  Data? data;

  EventDetailsModel({this.responseCode, this.message, this.data});

  EventDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? title;
  String? eventType;
  String? description;
  String? dateAndTime;
  String? location;
  String? poster;
  String? mla;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
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
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    eventType = json['eventType'];
    description = json['description'];
    dateAndTime = json['dateAndTime'];
    location = json['location'];
    poster = json['poster'];
    mla = json['mla'];
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
    data['mla'] = this.mla;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
