class UserProfileResponseModel {
  int? responseCode;
  String? message;
  Data? data;

  UserProfileResponseModel({this.responseCode, this.message, this.data});

  UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  String? phone;
  String? deviceToken;
  String? dateOfBirth;
  String? gender;
  String? avatar;
  bool? isRegistered;
  bool? isActive;
  String? token;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? address;

  Data(
      {this.sId,
      this.name,
      this.email,
      this.phone,
      this.deviceToken,
      this.dateOfBirth,
      this.gender,
      this.avatar,
      this.isRegistered,
      this.isActive,
      this.token,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.address});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    deviceToken = json['deviceToken'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    avatar = json['avatar'];
    isRegistered = json['isRegistered'];
    isActive = json['isActive'];
    token = json['token'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['deviceToken'] = this.deviceToken;
    data['dateOfBirth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['avatar'] = this.avatar;
    data['isRegistered'] = this.isRegistered;
    data['isActive'] = this.isActive;
    data['token'] = this.token;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['address'] = this.address;
    return data;
  }
}
