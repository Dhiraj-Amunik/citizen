class ConstituencyModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  ConstituencyModel({this.responseCode, this.message, this.data});

  ConstituencyModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? area;
  String? constituencyId;
  int? citizenCount;
  String? mlaName;
  String? state;
  String? district;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.name,
      this.area,
      this.constituencyId,
      this.citizenCount,
      this.mlaName,
      this.state,
      this.district,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    area = json['area'];
    constituencyId = json['constituencyId'];
    citizenCount = json['citizenCount'];
    mlaName = json['mlaName'];
    state = json['state'];
    district = json['district'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['area'] = this.area;
    data['constituencyId'] = this.constituencyId;
    data['citizenCount'] = this.citizenCount;
    data['mlaName'] = this.mlaName;
    data['state'] = this.state;
    data['district'] = this.district;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
