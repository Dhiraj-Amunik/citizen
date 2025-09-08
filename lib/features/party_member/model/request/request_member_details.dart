class RequestMemberDetails {
  String phoneNumber;
  
  RequestMemberDetails({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phoneNumber;
    return map;
  }
}
