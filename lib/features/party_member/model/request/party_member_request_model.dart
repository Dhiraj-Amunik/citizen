class PartyMemberRequestModel {
  final String? phone;
  final String? userName;
  final String? parentName;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? constituency;
  final String? avatar;
  final String? reason;
  final String? preferredRole;

  PartyMemberRequestModel({
    required this.phone,
    required this.userName,
    required this.parentName,
    required this.dateOfBirth,
    required this.gender,
    required this.maritalStatus,
    required this.constituency,
    required this.avatar,
    required this.reason,
    required this.preferredRole,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phone;
    map['userName'] = userName;
    map['parentName'] = parentName;
    map['dateOfBirth'] = dateOfBirth;
    map['gender'] = gender;
    map['maritalStatus'] = maritalStatus;
    map['constituency'] = constituency;
    map['avatar'] = avatar;
    map['reason'] = reason;
    map['preferredRole'] = preferredRole;
    return map;
  }
}
