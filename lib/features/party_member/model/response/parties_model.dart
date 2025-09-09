class PartiesModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  PartiesModel({this.responseCode, this.message, this.data});

  PartiesModel.fromJson(Map<String, dynamic> json) {
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
  String? abbreviation;
  String? symbol;
  String? leader;
  String? founded;
  int? mlaCount;
  List<String>? constituencies;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.name,
      this.abbreviation,
      this.symbol,
      this.leader,
      this.founded,
      this.mlaCount,
      this.constituencies,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    abbreviation = json['abbreviation'];
    symbol = json['symbol'];
    leader = json['leader'];
    founded = json['founded'];
    mlaCount = json['mlaCount'];
    constituencies = json['constituencies'].cast<String>();
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['abbreviation'] = this.abbreviation;
    data['symbol'] = this.symbol;
    data['leader'] = this.leader;
    data['founded'] = this.founded;
    data['mlaCount'] = this.mlaCount;
    data['constituencies'] = this.constituencies;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
