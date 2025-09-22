part "./constituency.dart";

class ConstituencyModel {
  int? responseCode;
  String? message;
  List<Constituency>? data;

  ConstituencyModel({this.responseCode, this.message, this.data});

  ConstituencyModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Constituency>[];
      json['data'].forEach((v) {
        data!.add(new Constituency.fromJson(v));
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
