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
  String? authorityName;
  String? threadId;
  String? toMail;
  List<Messages>? messages;
  String? status;
  bool? isActive;
  String? lastSyncedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.userId,
      this.department,
      this.authorityName,
      this.threadId,
      this.toMail,
      this.messages,
      this.status,
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
    authorityName = json['authorityName'];
    threadId = json['threadId'];
    toMail = json['toMail'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
    status = json['status'];
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
    data['authorityName'] = this.authorityName;
    data['threadId'] = this.threadId;
    data['toMail'] = this.toMail;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
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

class Messages {
  String? from;
  String? to;
  String? subject;
  String? snippet;
  String? date;
  String? body;
  List<Attachments>? attachments;
  String? sId;

  Messages(
      {this.from,
      this.to,
      this.subject,
      this.snippet,
      this.date,
      this.body,
      this.attachments,
      this.sId});

  Messages.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    subject = json['subject'];
    snippet = json['snippet'];
    date = json['date'];
    body = json['body'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['subject'] = this.subject;
    data['snippet'] = this.snippet;
    data['date'] = this.date;
    data['body'] = this.body;
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class Attachments {
  String? filename;
  String? mimeType;
  int? size;
  String? sId;

  Attachments({this.filename, this.mimeType, this.size, this.sId});

  Attachments.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
    mimeType = json['mimeType'];
    size = json['size'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filename'] = this.filename;
    data['mimeType'] = this.mimeType;
    data['size'] = this.size;
    data['_id'] = this.sId;
    return data;
  }
}
