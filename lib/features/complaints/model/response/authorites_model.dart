class AuthoritiesModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  AuthoritiesModel({this.responseCode, this.message, this.data});

  AuthoritiesModel.fromJson(Map<String, dynamic> json) {
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
  String? authorityId;
  String? name;
  String? designation;
  String? description;
  List<String>? email;
  String? phone;
  String? department;
  String? constituency;
  String? address;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.authorityId,
    this.name,
    this.designation,
    this.description,
    this.email,
    this.phone,
    this.department,
    this.constituency,
    this.address,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    authorityId = json['authorityId'];
    name = json['name'];
    designation = json['designation'];
    description = json['description'];
    email = json['email'].cast<String>();
    phone = json['phone'];
    department = json['department'];
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
    data['authorityId'] = this.authorityId;
    data['name'] = this.name;
    data['designation'] = this.designation;
    data['description'] = this.description;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['department'] = this.department;
    data['constituency'] = this.constituency;
    data['address'] = this.address;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
