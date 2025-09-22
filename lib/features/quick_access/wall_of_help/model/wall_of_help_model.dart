class WallOfHelpModel {
  int? responseCode;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  WallOfHelpModel(
      {this.responseCode, this.message, this.data, this.pagination});

  WallOfHelpModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  PartyMember? partyMember;
  String? name;
  String? title;
  String? phone;
  int? amountRequested;
  String? urgency;
  String? description;
  String? status;
  bool? isActive;
  bool? isDeleted;
  int? amountCollected;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.partyMember,
      this.name,
      this.title,
      this.phone,
      this.amountRequested,
      this.urgency,
      this.description,
      this.status,
      this.isActive,
      this.isDeleted,
      this.amountCollected,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    partyMember = json['partyMember'] != null
        ? new PartyMember.fromJson(json['partyMember'])
        : null;
    name = json['name'];
    title = json['title'];
    phone = json['phone'];
    amountRequested = json['amountRequested'];
    urgency = json['urgency'];
    description = json['description'];
    status = json['status'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    amountCollected = json['amountCollected'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.partyMember != null) {
      data['partyMember'] = this.partyMember!.toJson();
    }
    data['name'] = this.name;
    data['title'] = this.title;
    data['phone'] = this.phone;
    data['amountRequested'] = this.amountRequested;
    data['urgency'] = this.urgency;
    data['description'] = this.description;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['amountCollected'] = this.amountCollected;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class PartyMember {
  bool? isDeleted;
  String? sId;
  User? user;
  String? requestId;
  String? userName;
  String? parentName;
  String? maritalStatus;
  String? constituency;
  String? party;
  String? reason;
  String? preferredRole;
  String? status;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  PartyMember(
      {this.isDeleted,
      this.sId,
      this.user,
      this.requestId,
      this.userName,
      this.parentName,
      this.maritalStatus,
      this.constituency,
      this.party,
      this.reason,
      this.preferredRole,
      this.status,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.iV});

  PartyMember.fromJson(Map<String, dynamic> json) {
    isDeleted = json['isDeleted'];
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    requestId = json['requestId'];
    userName = json['userName'];
    parentName = json['parentName'];
    maritalStatus = json['maritalStatus'];
    constituency = json['constituency'];
    party = json['party'];
    reason = json['reason'];
    preferredRole = json['preferredRole'];
    status = json['status'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isDeleted'] = this.isDeleted;
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['requestId'] = this.requestId;
    data['userName'] = this.userName;
    data['parentName'] = this.parentName;
    data['maritalStatus'] = this.maritalStatus;
    data['constituency'] = this.constituency;
    data['party'] = this.party;
    data['reason'] = this.reason;
    data['preferredRole'] = this.preferredRole;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
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

  User({this.sId, this.name, this.email, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalPages'] = this.totalPages;
    return data;
  }
}
