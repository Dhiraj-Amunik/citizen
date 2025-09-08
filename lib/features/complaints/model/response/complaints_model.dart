class ComplaintsModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  ComplaintsModel({this.responseCode, this.message, this.data});

  ComplaintsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  UserId? userId;
  Department? department;
  Authority? authority;
  Constituency? constituency;
  String? threadId;
  String? toMail;
  List<Messages>? messages;
  bool? isActive;
  String? lastSyncedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.userId,
      this.department,
      this.authority,
      this.constituency,
      this.threadId,
      this.toMail,
      this.messages,
      this.isActive,
      this.lastSyncedAt,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId =
        json['userId'] != null ? new UserId.fromJson(json['userId']) : null;
    department = json['department'] != null
        ? new Department.fromJson(json['department'])
        : null;
    authority = json['authority'] != null
        ? new Authority.fromJson(json['authority'])
        : null;
    constituency = json['constituency'] != null
        ? new Constituency.fromJson(json['constituency'])
        : null;
    threadId = json['threadId'];
    toMail = json['toMail'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
    isActive = json['isActive'];
    lastSyncedAt = json['lastSyncedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.userId != null) {
      data['userId'] = this.userId!.toJson();
    }
    if (this.department != null) {
      data['department'] = this.department!.toJson();
    }
    if (this.authority != null) {
      data['authority'] = this.authority!.toJson();
    }
    if (this.constituency != null) {
      data['constituency'] = this.constituency!.toJson();
    }
    data['threadId'] = this.threadId;
    data['toMail'] = this.toMail;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    data['isActive'] = this.isActive;
    data['lastSyncedAt'] = this.lastSyncedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class UserId {
  String? sId;
  String? name;
  String? email;
  String? phone;

  UserId({this.sId, this.name, this.email, this.phone});

  UserId.fromJson(Map<String, dynamic> json) {
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

class Department {
  String? sId;
  String? departmentId;
  String? name;
  String? description;

  Department({this.sId, this.departmentId, this.name, this.description});

  Department.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    departmentId = json['departmentId'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['departmentId'] = this.departmentId;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}

class Authority {
  String? sId;
  String? authorityId;
  String? name;
  String? designation;

  Authority({this.sId, this.authorityId, this.name, this.designation});

  Authority.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    authorityId = json['authorityId'];
    name = json['name'];
    designation = json['designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['authorityId'] = this.authorityId;
    data['name'] = this.name;
    data['designation'] = this.designation;
    return data;
  }
}

class Constituency {
  String? sId;
  String? name;
  String? area;
  String? constituencyId;

  Constituency({this.sId, this.name, this.area, this.constituencyId});

  Constituency.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    area = json['area'];
    constituencyId = json['constituencyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['area'] = this.area;
    data['constituencyId'] = this.constituencyId;
    return data;
  }
}

class Messages {
  String? from;
  String? to;
  String? subject;
  String? snippet;
  String? date;
  String? body;
  String? sId;
  String? messageId;

  Messages(
      {this.from,
      this.to,
      this.subject,
      this.snippet,
      this.date,
      this.body,
      this.sId,
      this.messageId});

  Messages.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    subject = json['subject'];
    snippet = json['snippet'];
    date = json['date'];
    body = json['body'];
    sId = json['_id'];
    messageId = json['messageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['subject'] = this.subject;
    data['snippet'] = this.snippet;
    data['date'] = this.date;
    data['body'] = this.body;
    data['_id'] = this.sId;
    data['messageId'] = this.messageId;
    return data;
  }
}
