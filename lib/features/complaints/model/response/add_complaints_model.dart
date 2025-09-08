class AddComplaintsModel {
  bool? success;
  String? threadId;
  String? messageId;

  AddComplaintsModel({this.success, this.threadId, this.messageId});

  AddComplaintsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    threadId = json['threadId'];
    messageId = json['messageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['threadId'] = this.threadId;
    data['messageId'] = this.messageId;
    return data;
  }
}