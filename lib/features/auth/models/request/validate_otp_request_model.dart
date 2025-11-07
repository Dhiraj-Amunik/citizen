class OtpRequestModel {
  String phoneNo;
  String? otp;
  String? deviceType;
  String? deviceToken;

  OtpRequestModel({required this.phoneNo, this.otp, this.deviceType, this.deviceToken});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phoneNo;
    map['otp'] = otp;
    map['deviceType'] = deviceType;
    map['deviceToken'] = deviceToken;
    return map;
  }
}
