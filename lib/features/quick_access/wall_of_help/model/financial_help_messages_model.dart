class FinancialHelpMessagesModel {
  int? responseCode;
  String? message;
  FinancialHelpData? data;

  FinancialHelpMessagesModel({this.responseCode, this.message, this.data});

  FinancialHelpMessagesModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null
        ? new FinancialHelpData.fromJson(json['data'])
        : null;
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

class FinancialHelpData {
  int? page;
  int? pageSize;
  int? total;
  List<FinancialHelpChatData>? inbox;

  FinancialHelpData({this.page, this.pageSize, this.total, this.inbox});

  FinancialHelpData.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    total = json['total'];
    if (json['inbox'] != null) {
      inbox = <FinancialHelpChatData>[];
      json['inbox'].forEach((v) {
        inbox!.add(new FinancialHelpChatData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    data['total'] = this.total;
    if (this.inbox != null) {
      data['inbox'] = this.inbox!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FinancialHelpChatData {
  String? messageId;
  String? financialHelpRequest;
  RelatedUser? relatedUser;
  LastMessage? lastMessage;
  int? unreadCount;
  int? totalMessages;
  String? updatedAt;

  FinancialHelpChatData({
    this.messageId,
    this.financialHelpRequest,
    this.relatedUser,
    this.lastMessage,
    this.unreadCount,
    this.totalMessages,
    this.updatedAt,
  });

  FinancialHelpChatData.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    financialHelpRequest = json['financialHelpRequest'];
    relatedUser = json['relatedUser'] != null
        ? new RelatedUser.fromJson(json['relatedUser'])
        : null;
    lastMessage = json['lastMessage'] != null
        ? new LastMessage.fromJson(json['lastMessage'])
        : null;
    unreadCount = json['unreadCount'] ?? 0;
    totalMessages = json['totalMessages'] ?? 0;
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageId'] = this.messageId;
    data['financialHelpRequest'] = this.financialHelpRequest;
    if (this.relatedUser != null) {
      data['relatedUser'] = this.relatedUser!.toJson();
    }
    if (this.lastMessage != null) {
      data['lastMessage'] = this.lastMessage!.toJson();
    }
    data['unreadCount'] = this.unreadCount;
    data['totalMessages'] = this.totalMessages;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class RelatedUser {
  String? sId;
  String? user;
  String? requestId;
  String? userName;
  String? parentName;
  String? maritalStatus;
  String? reason;
  List<String>? images;
  String? memberShipId;
  String? status;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  RelatedUser({
    this.sId,
    this.user,
    this.requestId,
    this.userName,
    this.parentName,
    this.maritalStatus,
    this.reason,
    this.images,
    this.memberShipId,
    this.status,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  RelatedUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    requestId = json['requestId'];
    userName = json['userName'];
    parentName = json['parentName'];
    maritalStatus = json['maritalStatus'];
    reason = json['reason'];
    images = json['images'] != null ? json['images'].cast<String>() : [];
    memberShipId = json['memberShipId'];
    status = json['status'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['requestId'] = this.requestId;
    data['userName'] = this.userName;
    data['parentName'] = this.parentName;
    data['maritalStatus'] = this.maritalStatus;
    data['reason'] = this.reason;
    data['images'] = this.images;
    data['memberShipId'] = this.memberShipId;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class LastMessage {
  String? sender;
  String? receiver;
  String? senderModel;
  String? receiverModel;
  String? message;
  List<String>? documents;
  bool? isRead;
  String? date;
  String? sId;

  LastMessage({
    this.sender,
    this.receiver,
    this.senderModel,
    this.receiverModel,
    this.message,
    this.documents,
    this.isRead,
    this.date,
    this.sId,
  });

  LastMessage.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    receiver = json['receiver'];
    senderModel = json['senderModel'];
    receiverModel = json['receiverModel'];
    message = json['message'];
    documents = json['documents'] != null
        ? json['documents'].cast<String>()
        : [];
    isRead = json['isRead'] ?? false;
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
    data['isRead'] = this.isRead;
    data['date'] = this.date;
    data['_id'] = this.sId;
    return data;
  }
}
