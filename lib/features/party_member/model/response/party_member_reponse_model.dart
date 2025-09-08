class PartyMemberResponseModel {
  int? responseCode;
  String? message;
  Data? data;

  PartyMemberResponseModel({this.responseCode, this.message, this.data});

  PartyMemberResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? user;
  String? userName;
  String? parentName;
  String? maritalStatus;
  String? constituency;
  String? reason;
  String? preferredRole;
  String? status;
  bool? isActive;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.user,
      this.userName,
      this.parentName,
      this.maritalStatus,
      this.constituency,
      this.reason,
      this.preferredRole,
      this.status,
      this.isActive,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    userName = json['userName'];
    parentName = json['parentName'];
    maritalStatus = json['maritalStatus'];
    constituency = json['constituency'];
    reason = json['reason'];
    preferredRole = json['preferredRole'];
    status = json['status'];
    isActive = json['isActive'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.user;
    data['userName'] = this.userName;
    data['parentName'] = this.parentName;
    data['maritalStatus'] = this.maritalStatus;
    data['constituency'] = this.constituency;
    data['reason'] = this.reason;
    data['preferredRole'] = this.preferredRole;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
