class UpdateProfileModel {
  int? responseCode;
  String? message;
  Data? data;

  UpdateProfileModel({this.responseCode, this.message, this.data});

  UpdateProfileModel.fromJson(Map<String, dynamic> json) {
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
  String? email;
  String? gender;
  String? dateOfBirth;
  String? address;
  String? avatar;
  Location? location;
  String? constituency;
  String? whatsapp;
  String? fatherName;
  String? city;
  String? state;
  String? district;
  String? pincode;

  Data(
      {this.name,
      this.email,
      this.gender,
      this.dateOfBirth,
      this.address,
      this.avatar,
      this.location,
      this.constituency,
      this.whatsapp,
      this.fatherName,
      this.city,
      this.state,
      this.district,
      this.pincode});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
    address = json['address'];
    avatar = json['avatar'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    constituency = json['constituency'];
    whatsapp = json['whatsapp'];
    fatherName = json['fatherName'];
    city = json['city'];
    state = json['state'];
    district = json['district'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['dateOfBirth'] = this.dateOfBirth;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['constituency'] = this.constituency;
    data['whatsapp'] = this.whatsapp;
    data['fatherName'] = this.fatherName;
    data['city'] = this.city;
    data['state'] = this.state;
    data['district'] = this.district;
    data['pincode'] = this.pincode;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}
