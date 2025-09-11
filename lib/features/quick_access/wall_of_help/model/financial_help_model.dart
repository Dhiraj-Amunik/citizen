class FinancialHelpModel {
  int? responseCode;
  String? message;
  Data? data;

  FinancialHelpModel({this.responseCode, this.message, this.data});

  FinancialHelpModel.fromJson(Map<String, dynamic> json) {
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
  String? user;
  String? subject;
  String? reason;
  int? amountRequested;
  String? additionalDetails;
  String? party;
  String? constituency;
  List<Documents>? documents;
  String? status;
  bool? isActive;
  bool? isDeleted;
  int? amountCollected;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.user,
      this.subject,
      this.reason,
      this.amountRequested,
      this.additionalDetails,
      this.party,
      this.constituency,
      this.documents,
      this.status,
      this.isActive,
      this.isDeleted,
      this.amountCollected,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    subject = json['subject'];
    reason = json['reason'];
    amountRequested = json['amountRequested'];
    additionalDetails = json['additionalDetails'];
    party = json['party'];
    constituency = json['constituency'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(new Documents.fromJson(v));
      });
    }
    status = json['status'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    amountCollected = json['amountCollected'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.user;
    data['subject'] = this.subject;
    data['reason'] = this.reason;
    data['amountRequested'] = this.amountRequested;
    data['additionalDetails'] = this.additionalDetails;
    data['party'] = this.party;
    data['constituency'] = this.constituency;
    if (this.documents != null) {
      data['documents'] = this.documents!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['amountCollected'] = this.amountCollected;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Documents {
  String? fileName;
  String? fileUrl;
  String? sId;
  String? uploadedAt;

  Documents({this.fileName, this.fileUrl, this.sId, this.uploadedAt});

  Documents.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    fileUrl = json['fileUrl'];
    sId = json['_id'];
    uploadedAt = json['uploadedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['fileUrl'] = this.fileUrl;
    data['_id'] = this.sId;
    data['uploadedAt'] = this.uploadedAt;
    return data;
  }
}
