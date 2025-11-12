class MemberMessagesModel {
  int? responseCode;
  String? message;
  Data? data;

  MemberMessagesModel({this.responseCode, this.message, this.data});

  MemberMessagesModel.fromJson(Map<String, dynamic> json) {
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
  Mla? mla;
  PartyMember? partyMember;
  List<MessagesDetails>? messagesDetails;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.mla,
      this.partyMember,
      this.messagesDetails,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mla = json['mla'] != null ? new Mla.fromJson(json['mla']) : null;
    partyMember = json['partyMember'] != null
        ? new PartyMember.fromJson(json['partyMember'])
        : null;
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
    if (this.mla != null) {
      data['mla'] = this.mla!.toJson();
    }
    if (this.partyMember != null) {
      data['partyMember'] = this.partyMember!.toJson();
    }
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

class Mla {
  String? sId;
  User? user;
  Null? constituency;

  Mla({this.sId, this.user, this.constituency});

  Mla.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    constituency = json['constituency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['constituency'] = this.constituency;
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? avatar;

  User({this.sId, this.name, this.email, this.phone, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['avatar'] = this.avatar;
    return data;
  }
}

class PartyMember {
  String? sId;
  User? user;
  String? parentName;

  PartyMember({this.sId, this.user, this.parentName});

  PartyMember.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    parentName = json['parentName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['parentName'] = this.parentName;
    return data;
  }
}

class MessagesDetails {
  PartyMember? sender;
  PartyMember? receiver;
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
    sender = json['sender'] != null
        ? new PartyMember.fromJson(json['sender'])
        : null;
    receiver = json['receiver'] != null
        ? new PartyMember.fromJson(json['receiver'])
        : null;
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
