import 'package:flutter/foundation.dart';

class MyMembersChatModel {
  int? responseCode;
  String? message;
  List<Data>? data;
  int? totalUnreadCount;

  MyMembersChatModel({this.responseCode, this.message, this.data, this.totalUnreadCount});

  MyMembersChatModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    totalUnreadCount = json['totalUnreadCount'];
    
    debugPrint("📬 MyMembersChatModel.fromJson - json['data']: ${json['data']}");
    debugPrint("📬 MyMembersChatModel.fromJson - json['data'] is null: ${json['data'] == null}");
    debugPrint("📬 MyMembersChatModel.fromJson - json['data'] type: ${json['data'].runtimeType}");
    
    if (json['data'] != null) {
      data = <Data>[];
      // Handle both empty arrays and arrays with data
      if (json['data'] is List) {
        final dataList = json['data'] as List;
        debugPrint("📬 Parsing ${dataList.length} chat items");
        for (var v in dataList) {
          try {
            if (v is Map<String, dynamic>) {
              data!.add(new Data.fromJson(v));
            } else {
              debugPrint("📬 ⚠️ Item is not a Map: ${v.runtimeType}");
            }
          } catch (e) {
            debugPrint("📬 ❌ Error parsing chat data item: $e");
            debugPrint("📬 Item data: $v");
            // Continue parsing other items even if one fails
          }
        }
        debugPrint("📬 ✅ Successfully parsed ${data!.length} chats");
      } else {
        debugPrint("📬 ⚠️ json['data'] is not a List, it's: ${json['data'].runtimeType}");
      }
    } else {
      debugPrint("📬 ⚠️ json['data'] is null, initializing as empty list");
      data = <Data>[]; // Initialize as empty list if null
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalUnreadCount'] = this.totalUnreadCount;
    return data;
  }
}

class Data {
  String? chatId;
  String? chatWithType;
  ChatWith? chatWith;
  LastMessage? lastMessage;
  String? updatedAt;
  int? unreadMessages;

  Data(
      {this.chatId,
      this.chatWithType,
      this.chatWith,
      this.lastMessage,
      this.updatedAt,
      this.unreadMessages});

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
    unreadMessages = json['unreadMessages'];
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
    data['unreadMessages'] = this.unreadMessages;
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
  bool? isRead;

  LastMessage({this.text, this.date, this.senderType, this.isRead});

  LastMessage.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    date = json['date'];
    senderType = json['senderType'];
    isRead = json['isRead'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['date'] = this.date;
    data['senderType'] = this.senderType;
    data['isRead'] = this.isRead;
    return data;
  }
}
