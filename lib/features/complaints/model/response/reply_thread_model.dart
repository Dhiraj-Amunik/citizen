class ReplyThreadModel {
  int? responseCode;
  String? message;
  Data? data;

  ReplyThreadModel({this.responseCode, this.message, this.data});

  ReplyThreadModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? threadId;
  List<String>? labelIds;

  Data({this.id, this.threadId, this.labelIds});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    threadId = json['threadId'];
    labelIds = json['labelIds'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['threadId'] = this.threadId;
    data['labelIds'] = this.labelIds;
    return data;
  }
}
