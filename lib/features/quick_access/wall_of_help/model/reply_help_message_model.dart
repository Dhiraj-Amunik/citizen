class ReplyHelpMessagesModel {
  int? responseCode;
  String? message;
  Data? data;

  ReplyHelpMessagesModel({this.responseCode, this.message, this.data});

  ReplyHelpMessagesModel.fromJson(Map<String, dynamic> json) {
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
  String? sId;
  String? financialHelpRequest;
  String? partyMember;
  String? relatedId;
  String? relatedModel;
  List<MessagesDetails>? messagesDetails;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.financialHelpRequest,
      this.partyMember,
      this.relatedId,
      this.relatedModel,
      this.messagesDetails,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    financialHelpRequest = json['financialHelpRequest'];
    partyMember = json['partyMember'];
    relatedId = json['relatedId'];
    relatedModel = json['relatedModel'];
    if (json['messagesDetails'] != null) {
      messagesDetails = <MessagesDetails>[];
      json['messagesDetails'].forEach((v) {
        messagesDetails!.add(new MessagesDetails.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['financialHelpRequest'] = this.financialHelpRequest;
    data['partyMember'] = this.partyMember;
    data['relatedId'] = this.relatedId;
    data['relatedModel'] = this.relatedModel;
    if (this.messagesDetails != null) {
      data['messagesDetails'] =
          this.messagesDetails!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class MessagesDetails {
  String? sender;
  String? receiver;
  String? senderModel;
  String? receiverModel;
  String? message;
  List<String>? documents;
  String? date;
  String? sId;

  MessagesDetails(
      {this.sender,
      this.receiver,
      this.senderModel,
      this.receiverModel,
      this.message,
      this.documents,
      this.date,
      this.sId});

  MessagesDetails.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    receiver = json['receiver'];
    senderModel = json['senderModel'];
    receiverModel = json['receiverModel'];
    message = json['message'];
    documents = json['documents'].cast<String>();
    date = json['date'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sender'] = this.sender;
    data['receiver'] = this.receiver;
    data['senderModel'] = this.senderModel;
    data['receiverModel'] = this.receiverModel;
    data['message'] = this.message;
    data['documents'] = this.documents;
    data['date'] = this.date;
    data['_id'] = this.sId;
    return data;
  }
}
