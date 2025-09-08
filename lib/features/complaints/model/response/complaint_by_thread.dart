class ComplaintsByThreadsModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  ComplaintsByThreadsModel({this.responseCode, this.message, this.data});

  ComplaintsByThreadsModel.fromJson(Map<String, dynamic> json) {
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
  String? messageId;
  String? threadId;
  String? from;
  String? subject;
  String? snippet;
  String? receivedAt;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.messageId,
      this.threadId,
      this.from,
      this.subject,
      this.snippet,
      this.receivedAt,
      this.type,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    messageId = json['messageId'];
    threadId = json['threadId'];
    from = json['from'];
    subject = json['subject'];
    snippet = json['snippet'];
    receivedAt = json['receivedAt'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['messageId'] = this.messageId;
    data['threadId'] = this.threadId;
    data['from'] = this.from;
    data['subject'] = this.subject;
    data['snippet'] = this.snippet;
    data['receivedAt'] = this.receivedAt;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
