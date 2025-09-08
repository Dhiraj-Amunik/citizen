class ComplaintDepatmentsModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  ComplaintDepatmentsModel({this.responseCode, this.message, this.data});

  ComplaintDepatmentsModel.fromJson(Map<String, dynamic> json) {
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
  String? departmentId;
  String? name;
  String? description;
  String? email;
  String? phone;
  String? website;
  String? constituency;
  String? address;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.departmentId,
      this.name,
      this.description,
      this.email,
      this.phone,
      this.website,
      this.constituency,
      this.address,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    departmentId = json['departmentId'];
    name = json['name'];
    description = json['description'];
    email = json['email'];
    phone = json['phone'];
    website = json['website'];
    constituency = json['constituency'];
    address = json['address'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['departmentId'] = this.departmentId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['website'] = this.website;
    data['constituency'] = this.constituency;
    data['address'] = this.address;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
