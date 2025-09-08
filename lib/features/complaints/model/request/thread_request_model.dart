class ThreadRequestModel {
  String? threadID;

  ThreadRequestModel({this.threadID});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['threadId'] = this.threadID;
    return data;
  }
}
