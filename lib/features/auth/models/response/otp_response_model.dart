class OTPResponseModel {
  String? message;
  int? responseCode;
  Data? data;

  OTPResponseModel({this.message, this.responseCode, this.data});

  OTPResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    responseCode = json['responseCode'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['responseCode'] = this.responseCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? otp;
  String? token;
  bool? isRegistered;
  bool? isPartyMember;

  Data({this.otp, this.token, this.isRegistered, this.isPartyMember});

  Data.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    token = json['token'];
    isRegistered = json['isRegistered'];
    isPartyMember = json['isPartyMember'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp'] = this.otp;
    data['token'] = this.token;
    data['isRegistered'] = this.isRegistered;
    data['isPartyMember'] = this.isPartyMember;
    return data;
  }
}
