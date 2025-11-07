import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;

class LokVartaDetailsModel {
  int? responseCode;
  String? message;
  model.Media? data;

  LokVartaDetailsModel({this.responseCode, this.message, this.data});

  LokVartaDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null ? new  model.Media.fromJson(json['data']) : null;
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