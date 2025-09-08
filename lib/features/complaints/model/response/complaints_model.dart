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
  String? threadId;
  String? subject;
  int? messageCount;
  List<Messages>? messages;
  String? user;
  String? department;
  String? officer;
  String? lastSyncedAt;
  int? iV;

  Data(
      {this.sId,
      this.threadId,
      this.subject,
      this.messageCount,
      this.messages,
      this.user,
      this.department,
      this.officer,
      this.lastSyncedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    threadId = json['threadId'];
    subject = json['subject'];
    messageCount = json['messageCount'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
    user = json['user'];
    department = json['department'];
    officer = json['officer'];
    lastSyncedAt = json['lastSyncedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['threadId'] = this.threadId;
    data['subject'] = this.subject;
    data['messageCount'] = this.messageCount;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    data['user'] = this.user;
    data['department'] = this.department;
    data['officer'] = this.officer;
    data['lastSyncedAt'] = this.lastSyncedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Messages {
  String? messageId;
  String? from;
  String? to;
  String? subject;
  String? snippet;
  String? date;
  String? body;
  String? sId;

  Messages(
      {this.messageId,
      this.from,
      this.to,
      this.subject,
      this.snippet,
      this.date,
      this.body,
      this.sId});

  Messages.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    from = json['from'];
    to = json['to'];
    subject = json['subject'];
    snippet = json['snippet'];
    date = json['date'];
    body = json['body'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageId'] = this.messageId;
    data['from'] = this.from;
    data['to'] = this.to;
    data['subject'] = this.subject;
    data['snippet'] = this.snippet;
    data['date'] = this.date;
    data['body'] = this.body;
    data['_id'] = this.sId;
    return data;
  }
}
