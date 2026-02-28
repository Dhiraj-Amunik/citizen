class MarkReadResponse {
  int? responseCode;
  String? message;
  MarkReadData? data;

  MarkReadResponse({this.responseCode, this.message, this.data});

  MarkReadResponse.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null ? MarkReadData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class MarkReadData {
  int? modifiedCount;
  String? message;

  MarkReadData({this.modifiedCount, this.message});

  MarkReadData.fromJson(Map<String, dynamic> json) {
    modifiedCount = json['modifiedCount'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['modifiedCount'] = modifiedCount;
    data['message'] = message;
    return data;
  }
}
