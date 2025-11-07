class SuccessModel {
  int? responseCode;
  String? message;

  SuccessModel({this.responseCode, this.message});

  SuccessModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    return data;
  }
}
