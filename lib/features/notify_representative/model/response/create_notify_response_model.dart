import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';

class CreateNotifyResponseModel {
  int? responseCode;
  String? message;
  NotifyRepresentative? data;

  CreateNotifyResponseModel({this.responseCode, this.message, this.data});

  CreateNotifyResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null
        ? NotifyRepresentative.fromJson(json['data'])
        : null;
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
