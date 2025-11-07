class ComplaintsByThreadsModel {
  List<Data>? data;
  int? responseCode;
  String? message;

  ComplaintsByThreadsModel({this.data, this.responseCode, this.message});

  ComplaintsByThreadsModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    responseCode = json['responseCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? messageId;
  String? from;
  String? to;
  String? subject;
  String? snippet;
  String? date;
  String? body;
  List<Attachments>? attachments;

  Data(
      {this.messageId,
      this.from,
      this.to,
      this.subject,
      this.snippet,
      this.date,
      this.body,
      this.attachments});

  Data.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
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
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attachments {
  String? filename;
  String? mimeType;
  int? size;
  String? url;

  Attachments({this.filename, this.mimeType, this.size, this.url});

  Attachments.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
    mimeType = json['mimeType'];
    size = json['size'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filename'] = this.filename;
    data['mimeType'] = this.mimeType;
    data['size'] = this.size;
    data['url'] = this.url;
    return data;
  }
}
