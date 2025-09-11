class DonatedModel {
  int? responseCode;
  String? message;
  Data? data;

  DonatedModel({this.responseCode, this.message, this.data});

  DonatedModel.fromJson(Map<String, dynamic> json) {
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
  String? requestId;
  int? amountDonated;
  int? totalCollected;
  int? amountRequested;

  Data(
      {this.requestId,
      this.amountDonated,
      this.totalCollected,
      this.amountRequested});

  Data.fromJson(Map<String, dynamic> json) {
    requestId = json['requestId'];
    amountDonated = json['amountDonated'];
    totalCollected = json['totalCollected'];
    amountRequested = json['amountRequested'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requestId'] = this.requestId;
    data['amountDonated'] = this.amountDonated;
    data['totalCollected'] = this.totalCollected;
    data['amountRequested'] = this.amountRequested;
    return data;
  }
}
