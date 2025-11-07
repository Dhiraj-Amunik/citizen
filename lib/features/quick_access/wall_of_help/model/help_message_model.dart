class HelpMessagesModel {
  int? responseCode;
  String? message;
  Data? data;

  HelpMessagesModel({this.responseCode, this.message, this.data});

  HelpMessagesModel.fromJson(Map<String, dynamic> json) {
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
  Sender? sender;
  Sender? receiver;
  String? senderModel;
  String? receiverModel;
  String? message;
  List<String>? documents;
  String? date;
  String? sId;
  bool? isSent;
  bool? isReceived;

  MessagesDetails(
      {this.sender,
      this.receiver,
      this.senderModel,
      this.receiverModel,
      this.message,
      this.documents,
      this.date,
      this.sId,
      this.isSent,
      this.isReceived});

  MessagesDetails.fromJson(Map<String, dynamic> json) {
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    receiver =
        json['receiver'] != null ? new Sender.fromJson(json['receiver']) : null;
    senderModel = json['senderModel'];
    receiverModel = json['receiverModel'];
    message = json['message'];
    documents = json['documents'].cast<String>();
    date = json['date'];
    sId = json['_id'];
    isSent = json['isSent'];
    isReceived = json['isReceived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    if (this.receiver != null) {
      data['receiver'] = this.receiver!.toJson();
    }
    data['senderModel'] = this.senderModel;
    data['receiverModel'] = this.receiverModel;
    data['message'] = this.message;
    data['documents'] = this.documents;
    data['date'] = this.date;
    data['_id'] = this.sId;
    data['isSent'] = this.isSent;
    data['isReceived'] = this.isReceived;
    return data;
  }
}

class Sender {
  String? sId;
  User? user;

  Sender({this.sId, this.user});

  Sender.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? avatar;

  User({this.sId, this.name, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    return data;
  }
}
