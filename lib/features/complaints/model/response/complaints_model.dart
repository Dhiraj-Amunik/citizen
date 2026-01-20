class ComplaintsModel {
  int? responseCode;
  String? message;
  List<Data>? data;
  int? unreadMessageCount;

  ComplaintsModel({this.responseCode, this.message, this.data, this.unreadMessageCount});

  ComplaintsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    unreadMessageCount = json['unreadMessageCount'];
    if (json['data'] != null) {
      // Handle changed API response structure
      final dataValue = json['data'];
      
      if (dataValue is List) {
        // Original structure: data is a list
        data = <Data>[];
        dataValue.forEach((v) {
          try {
            if (v is Map<String, dynamic>) {
              data!.add(new Data.fromJson(v));
            } else if (v is Data) {
              data!.add(v);
            }
          } catch (e) {
            // Skip invalid items
            print("Error parsing complaint item: $e");
          }
        });
      } else if (dataValue is Map<String, dynamic>) {
        // New structure: data might be wrapped in an object
        // Check for common keys
        final possibleKeys = ['complaints', 'data', 'items', 'results', 'list'];
        List<dynamic>? listData;
        
        for (final key in possibleKeys) {
          if (dataValue.containsKey(key) && dataValue[key] is List) {
            listData = dataValue[key] as List;
            break;
          }
        }
        
        if (listData != null) {
          data = <Data>[];
          listData.forEach((v) {
            try {
              if (v is Map<String, dynamic>) {
                data!.add(new Data.fromJson(v));
              } else if (v is Data) {
                data!.add(v);
              }
            } catch (e) {
              // Skip invalid items
              print("Error parsing complaint item: $e");
            }
          });
        } else {
          // Try to parse the entire map as a single complaint
          try {
            data = [Data.fromJson(dataValue)];
          } catch (e) {
            print("Error parsing complaint from data object: $e");
            data = <Data>[];
          }
        }
      } else {
        // Unknown structure, set to empty list
        data = <Data>[];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.unreadMessageCount != null) {
      data['unreadMessageCount'] = this.unreadMessageCount;
    }
    return data;
  }
}

class Data {
  String? sId;
  UserId? userId;
  ComplaintUser? user;
  Department? department;
  String? authorityName;
  String? threadId;
  String? toMail;
  List<Messages>? messages;
  String? status;
  bool? isActive;
  String? lastSyncedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isFollowUpDue;
  String? followUpQuestion;
  List<String>? followUpOptions;
  int? unreadMessageCount;

  Data(
      {this.sId,
      this.userId,
      this.department,
      this.authorityName,
      this.threadId,
      this.toMail,
      this.messages,
      this.status,
      this.isActive,
      this.lastSyncedAt,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.isFollowUpDue,
      this.followUpQuestion,
      this.followUpOptions,
      this.unreadMessageCount});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId =
        json['userId'] != null ? new UserId.fromJson(json['userId']) : null;
    user = json['user'] != null ? ComplaintUser.fromJson(json['user']) : null;
    department = json['department'] != null
        ? new Department.fromJson(json['department'])
        : null;
    authorityName = json['authorityName'];
    threadId = json['threadId'];
    toMail = json['toMail'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
    status = json['status'];
    isActive = json['isActive'];
    lastSyncedAt = json['lastSyncedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isFollowUpDue = json['isFollowUpDue'];
    followUpQuestion = json['followUpQuestion'];
    followUpOptions = json['followUpOptions'] != null
        ? List<String>.from(json['followUpOptions'])
        : null;
    unreadMessageCount = json['unreadMessageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.userId != null) {
      data['userId'] = this.userId!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (this.department != null) {
      data['department'] = this.department!.toJson();
    }
    data['authorityName'] = this.authorityName;
    data['threadId'] = this.threadId;
    data['toMail'] = this.toMail;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['lastSyncedAt'] = this.lastSyncedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['isFollowUpDue'] = this.isFollowUpDue;
    if (this.followUpQuestion != null) {
      data['followUpQuestion'] = this.followUpQuestion;
    }
    if (this.followUpOptions != null) {
      data['followUpOptions'] = this.followUpOptions;
    }
    if (this.unreadMessageCount != null) {
      data['unreadMessageCount'] = this.unreadMessageCount;
    }
    return data;
  }
}

class UserId {
  String? sId;
  String? name;
  String? email;
  String? phone;

  UserId({this.sId, this.name, this.email, this.phone});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Department {
  String? sId;
  String? departmentId;
  String? name;
  String? description;

  Department({this.sId, this.departmentId, this.name, this.description});

  Department.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    departmentId = json['departmentId'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['departmentId'] = this.departmentId;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}

class Messages {
  String? from;
  String? to;
  String? subject;
  String? snippet;
  String? date;
  String? body;
  String? normalizedBody;
  List<Attachments>? attachments;
  String? sId;
  String? profileImage;
  String? senderName;
  String? userImage;
  bool? isRead;
  String? readAt;

  Messages(
      {this.from,
      this.to,
      this.subject,
      this.snippet,
      this.date,
      this.body,
      this.normalizedBody,
      this.attachments,
      this.sId,
      this.isRead,
      this.readAt});

  Messages.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    subject = json['subject'];
    snippet = json['snippet'];
    date = json['date'];
    body = json['body'];
    normalizedBody = json['normalizedBody'];
    profileImage = json['profileImage'] ?? json['profilePic'];
    senderName = json['senderName'] ?? json['fromName'];
    userImage = json['userImage'] ?? json['memberImage'];
    isRead = json['isRead'];
    readAt = json['readAt'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['subject'] = this.subject;
    data['snippet'] = this.snippet;
    data['date'] = this.date;
    data['body'] = this.body;
    if (profileImage != null) {
      data['profileImage'] = profileImage;
    }
    if (senderName != null) {
      data['senderName'] = senderName;
    }
    if (userImage != null) {
      data['userImage'] = userImage;
    }
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    if (this.isRead != null) {
      data['isRead'] = this.isRead;
    }
    if (this.readAt != null) {
      data['readAt'] = this.readAt;
    }
    return data;
  }
}

class ComplaintUser {
  ComplaintUser({
    this.avatar,
    this.name,
    this.email,
    this.phone,
  });

  factory ComplaintUser.fromJson(Map<String, dynamic> json) {
    return ComplaintUser(
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  final String? avatar;
  final String? name;
  final String? email;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class Attachments {
  String? filename;
  String? mimeType;
  int? size;
  String? sId;

  Attachments({this.filename, this.mimeType, this.size, this.sId});

  Attachments.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
    mimeType = json['mimeType'];
    size = json['size'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filename'] = this.filename;
    data['mimeType'] = this.mimeType;
    data['size'] = this.size;
    data['_id'] = this.sId;
    return data;
  }
}
