class DonationHistoryModel {
  int? responseCode;
  String? message;
  Data? data;

  DonationHistoryModel({this.responseCode, this.message, this.data});

  DonationHistoryModel.fromJson(Map<String, dynamic> json) {
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
  int? totalDonations;
  int? page;
  int? pageSize;
  List<Donations>? donations;

  Data({this.totalDonations, this.page, this.pageSize, this.donations});

  Data.fromJson(Map<String, dynamic> json) {
    totalDonations = json['totalDonations'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['donations'] != null) {
      donations = <Donations>[];
      json['donations'].forEach((v) {
        donations!.add(new Donations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalDonations'] = this.totalDonations;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.donations != null) {
      data['donations'] = this.donations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Donations {
  String? sId;
  User? user;
  String? userName;
  String? amount;
  String? purpose;
  String? currency;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Donations(
      {this.sId,
      this.user,
      this.userName,
      this.amount,
      this.purpose,
      this.currency,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Donations.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    userName = json['userName'];
    amount = json['amount'];
    purpose = json['purpose'];
    currency = json['currency'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['userName'] = this.userName;
    data['amount'] = this.amount;
    data['purpose'] = this.purpose;
    data['currency'] = this.currency;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? gender;
  String? avatar;
  String? address;

  User(
      {this.sId,
      this.name,
      this.email,
      this.phone,
      this.gender,
      this.avatar,
      this.address});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    gender = json['gender'];
    avatar = json['avatar'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['gender'] = this.gender;
    data['avatar'] = this.avatar;
    data['address'] = this.address;
    return data;
  }
}
