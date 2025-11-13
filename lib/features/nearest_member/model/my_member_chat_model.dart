class MyMembersChatModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  MyMembersChatModel({this.responseCode, this.message, this.data});

  MyMembersChatModel.fromJson(Map<String, dynamic> json) {
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
  String? chatId;
  String? chatWithType;
  ChatWith? chatWith;
  LastMessage? lastMessage;
  String? updatedAt;

  Data(
      {this.chatId,
      this.chatWithType,
      this.chatWith,
      this.lastMessage,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    chatId = json['chatId'];
    chatWithType = json['chatWithType'];
    chatWith = json['chatWith'] != null
        ? new ChatWith.fromJson(json['chatWith'])
        : null;
    lastMessage = json['lastMessage'] != null
        ? new LastMessage.fromJson(json['lastMessage'])
        : null;
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatId'] = this.chatId;
    data['chatWithType'] = this.chatWithType;
    if (this.chatWith != null) {
      data['chatWith'] = this.chatWith!.toJson();
    }
    if (this.lastMessage != null) {
      data['lastMessage'] = this.lastMessage!.toJson();
    }
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class ChatWith {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? avatar;

  ChatWith({this.sId, this.name, this.email, this.phone, this.avatar});

  ChatWith.fromJson(Map<String, dynamic> json) {
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

class LastMessage {
  String? text;
  String? date;
  String? senderType;

  LastMessage({this.text, this.date, this.senderType});

  LastMessage.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    date = json['date'];
    senderType = json['senderType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['date'] = this.date;
    data['senderType'] = this.senderType;
    return data;
  }
}
