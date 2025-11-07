class MLADetailsModel {
  int? responseCode;
  String? message;
  Data? data;

  MLADetailsModel({this.responseCode, this.message, this.data});

  MLADetailsModel.fromJson(Map<String, dynamic> json) {
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
  Mla? mla;

  Data({this.sId, this.mla});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mla = json['mla'] != null ? new Mla.fromJson(json['mla']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.mla != null) {
      data['mla'] = this.mla!.toJson();
    }
    return data;
  }
}

class Mla {
  String? sId;
  User? user;
  String? constituency;
  String? party;
  String? address;
  String? avatar;
  List<SocialMediaLinks>? socialMediaLinks;

  Mla(
      {this.sId,
      this.user,
      this.constituency,
      this.party,
      this.address,
      this.avatar,
      this.socialMediaLinks});

  Mla.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    constituency = json['constituency'];
    party = json['party'];
    address = json['address'];
    avatar = json['avatar'];
    if (json['socialMediaLinks'] != null) {
      socialMediaLinks = <SocialMediaLinks>[];
      json['socialMediaLinks'].forEach((v) {
        socialMediaLinks!.add(new SocialMediaLinks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['constituency'] = this.constituency;
    data['party'] = this.party;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    if (this.socialMediaLinks != null) {
      data['socialMediaLinks'] =
          this.socialMediaLinks!.map((v) => v.toJson()).toList();
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

class SocialMediaLinks {
  String? platform;
  String? url;
  String? sId;

  SocialMediaLinks({this.platform, this.url, this.sId});

  SocialMediaLinks.fromJson(Map<String, dynamic> json) {
    platform = json['platform'];
    url = json['url'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['platform'] = this.platform;
    data['url'] = this.url;
    data['_id'] = this.sId;
    return data;
  }
}
