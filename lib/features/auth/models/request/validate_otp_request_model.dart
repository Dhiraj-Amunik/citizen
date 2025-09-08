class OtpRequestModel {
  String phoneNo;
  String? otp;

  OtpRequestModel({required this.phoneNo, this.otp});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phoneNo;
    map['otp'] = otp;
    return map;
  }
}
