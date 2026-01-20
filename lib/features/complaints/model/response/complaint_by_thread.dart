class ComplaintsByThreadsModel {
  // For backward compatibility: keep List<Data> for old structure
  List<Data>? data;
  // For new structure: single complaint object with messages
  ComplaintThreadData? complaintData;
  int? responseCode;
  String? message;

  ComplaintsByThreadsModel({
    this.data,
    this.complaintData,
    this.responseCode,
    this.message,
  });

  ComplaintsByThreadsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    
    if (json['data'] != null) {
      final dataValue = json['data'];
      
      // Check if data is a List (old structure)
      if (dataValue is List) {
        data = <Data>[];
        dataValue.forEach((v) {
          try {
            if (v is Map<String, dynamic>) {
              data!.add(new Data.fromJson(v));
            } else if (v is Data) {
              data!.add(v);
            }
          } catch (e) {
            print("Error parsing thread message item: $e");
          }
        });
      } 
      // Check if data is a Map (new structure)
      else if (dataValue is Map<String, dynamic>) {
        try {
          complaintData = ComplaintThreadData.fromJson(dataValue);
          // Extract messages from complaintData for backward compatibility
          if (complaintData?.messages != null) {
            data = complaintData!.messages!
                .map((msg) => Data.fromMessage(msg))
                .toList();
          }
        } catch (e) {
          print("Error parsing complaint thread data: $e");
          data = <Data>[];
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.complaintData != null) {
      data['data'] = this.complaintData!.toJson();
    }
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? messageId;
  String? from;
  String? to;
  String? subject;
  String? snippet;
  String? date;
  String? body;
  String? normalizedBody;
  List<Attachments>? attachments;
  bool? isRead;
  String? readAt;
  bool? isDeleted;
  String? sId;

  Data({
    this.messageId,
    this.from,
    this.to,
    this.subject,
    this.snippet,
    this.date,
    this.body,
    this.normalizedBody,
    this.attachments,
    this.isRead,
    this.readAt,
    this.isDeleted,
    this.sId,
  });

  Data.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    from = json['from'];
    to = json['to'];
    subject = json['subject'];
    snippet = json['snippet'];
    date = json['date'];
    body = json['body'];
    normalizedBody = json['normalizedBody'];
    isRead = json['isRead'];
    readAt = json['readAt'];
    isDeleted = json['isDeleted'];
    sId = json['_id'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
  }

  // Factory constructor to create Data from Message object
  factory Data.fromMessage(Message message) {
    return Data(
      messageId: message.messageId,
      from: message.from,
      to: message.to,
      subject: message.subject,
      snippet: message.snippet,
      date: message.date,
      body: message.body,
      normalizedBody: message.normalizedBody,
      attachments: message.attachments,
      isRead: message.isRead,
      readAt: message.readAt,
      isDeleted: message.isDeleted,
      sId: message.sId,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageId'] = this.messageId;
    data['from'] = this.from;
    data['to'] = this.to;
    data['subject'] = this.subject;
    data['snippet'] = this.snippet;
    data['date'] = this.date;
    data['body'] = this.body;
    if (this.isRead != null) {
      data['isRead'] = this.isRead;
    }
    if (this.readAt != null) {
      data['readAt'] = this.readAt;
    }
    if (this.isDeleted != null) {
      data['isDeleted'] = this.isDeleted;
    }
    if (this.sId != null) {
      data['_id'] = this.sId;
    }
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attachments {
  String? filename;
  String? mimeType;
  int? size;
  String? url;
  String? sId;

  Attachments({this.filename, this.mimeType, this.size, this.url, this.sId});

  Attachments.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
    mimeType = json['mimeType'];
    size = json['size'];
    url = json['url'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filename'] = this.filename;
    data['mimeType'] = this.mimeType;
    data['size'] = this.size;
    if (this.url != null) {
      data['url'] = this.url;
    }
    if (this.sId != null) {
      data['_id'] = this.sId;
    }
    return data;
  }
}

// New model classes for the updated API response structure
class ComplaintThreadData {
  String? sId;
  ThreadUserId? userId;
  ThreadDepartment? department;
  ThreadAuthority? authority;
  ThreadConstituency? constituency;
  String? threadId;
  String? toMail;
  List<String>? cc;
  List<Message>? messages;
  String? status;
  int? followUpCount;
  String? nextFollowUpDate;
  bool? isActive;
  bool? isDeleted;
  String? updatedBy;
  String? updatedByModel;
  String? userType;
  int? level;
  String? lastSyncedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? nextAction;
  bool? isFollowUpDue;
  String? followUpQuestion;
  List<String>? followUpOptions;
  List<FollowUpQuestion>? followUpQuestions;
  ThreadFeedback? feedback;
  String? currentCase;
  bool? isflowClosed;
  String? flowCloasedMessage;

  ComplaintThreadData({
    this.sId,
    this.userId,
    this.department,
    this.authority,
    this.constituency,
    this.threadId,
    this.toMail,
    this.cc,
    this.messages,
    this.status,
    this.followUpCount,
    this.nextFollowUpDate,
    this.isActive,
    this.isDeleted,
    this.updatedBy,
    this.updatedByModel,
    this.userType,
    this.level,
    this.lastSyncedAt,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.nextAction,
    this.isFollowUpDue,
    this.followUpQuestion,
    this.followUpOptions,
    this.followUpQuestions,
    this.feedback,
    this.currentCase,
    this.isflowClosed,
    this.flowCloasedMessage,
  });

  factory ComplaintThreadData.fromJson(Map<String, dynamic> json) {
    return ComplaintThreadData(
      sId: json['_id'],
      userId: json['userId'] != null
          ? ThreadUserId.fromJson(json['userId'])
          : null,
      department: json['department'] != null
          ? ThreadDepartment.fromJson(json['department'])
          : null,
      authority: json['authority'] != null
          ? ThreadAuthority.fromJson(json['authority'])
          : null,
      constituency: json['constituency'] != null
          ? ThreadConstituency.fromJson(json['constituency'])
          : null,
      threadId: json['threadId'],
      toMail: json['toMail'],
      cc: json['CC'] != null ? List<String>.from(json['CC']) : null,
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((v) => Message.fromJson(v))
              .toList()
          : null,
      status: json['status'],
      followUpCount: json['followUpCount'],
      nextFollowUpDate: json['nextFollowUpDate'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      updatedBy: json['updatedBy'],
      updatedByModel: json['updatedByModel'],
      userType: json['userType'],
      level: json['level'],
      lastSyncedAt: json['lastSyncedAt'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
      nextAction: json['nextAction'],
      isFollowUpDue: json['isFollowUpDue'],
      followUpQuestion: json['followUpQuestion'],
      followUpOptions: json['followUpOptions'] != null
          ? List<String>.from(json['followUpOptions'])
          : null,
      followUpQuestions: json['followUpQuestions'] != null
          ? (json['followUpQuestions'] as List)
              .map((v) => FollowUpQuestion.fromJson(v))
              .toList()
          : null,
      feedback: json['feedback'] != null
          ? ThreadFeedback.fromJson(json['feedback'])
          : null,
      currentCase: json['currentCase'],
      isflowClosed: json['isflowClosed'],
      flowCloasedMessage: json['flowCloasedMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    if (department != null) {
      data['department'] = department!.toJson();
    }
    if (authority != null) {
      data['authority'] = authority!.toJson();
    }
    if (constituency != null) {
      data['constituency'] = constituency!.toJson();
    }
    data['threadId'] = threadId;
    data['toMail'] = toMail;
    if (cc != null) {
      data['CC'] = cc;
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    if (followUpCount != null) {
      data['followUpCount'] = followUpCount;
    }
    if (nextFollowUpDate != null) {
      data['nextFollowUpDate'] = nextFollowUpDate;
    }
    if (isActive != null) {
      data['isActive'] = isActive;
    }
    if (isDeleted != null) {
      data['isDeleted'] = isDeleted;
    }
    if (updatedBy != null) {
      data['updatedBy'] = updatedBy;
    }
    if (updatedByModel != null) {
      data['updatedByModel'] = updatedByModel;
    }
    if (userType != null) {
      data['userType'] = userType;
    }
    if (level != null) {
      data['level'] = level;
    }
    if (lastSyncedAt != null) {
      data['lastSyncedAt'] = lastSyncedAt;
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    if (iV != null) {
      data['__v'] = iV;
    }
    if (nextAction != null) {
      data['nextAction'] = nextAction;
    }
    if (isFollowUpDue != null) {
      data['isFollowUpDue'] = isFollowUpDue;
    }
    if (followUpQuestion != null) {
      data['followUpQuestion'] = followUpQuestion;
    }
    if (followUpOptions != null) {
      data['followUpOptions'] = followUpOptions;
    }
    if (followUpQuestions != null) {
      data['followUpQuestions'] = followUpQuestions!.map((v) => v.toJson()).toList();
    }
    if (feedback != null) {
      data['feedback'] = feedback!.toJson();
    }
    if (currentCase != null) {
      data['currentCase'] = currentCase;
    }
    if (isflowClosed != null) {
      data['isflowClosed'] = isflowClosed;
    }
    if (flowCloasedMessage != null) {
      data['flowCloasedMessage'] = flowCloasedMessage;
    }
    return data;
  }
}

class FollowUpQuestion {
  String? question;
  List<String>? options;
  String? answer;
  String? sId;
  bool? isRead;

  FollowUpQuestion({
    this.question,
    this.options,
    this.answer,
    this.sId,
    this.isRead,
  });

  factory FollowUpQuestion.fromJson(Map<String, dynamic> json) {
    return FollowUpQuestion(
      question: json['question'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      answer: json['answer'],
      sId: json['_id'],
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (question != null) {
      data['question'] = question;
    }
    if (options != null) {
      data['options'] = options;
    }
    if (answer != null) {
      data['answer'] = answer;
    }
    if (sId != null) {
      data['_id'] = sId;
    }
    if (isRead != null) {
      data['isRead'] = isRead;
    }
    return data;
  }
}

class ThreadFeedback {
  String? message;
  String? feedbackType;
  int? rating;
  String? feedbackAt;

  ThreadFeedback({
    this.message,
    this.feedbackType,
    this.rating,
    this.feedbackAt,
  });

  factory ThreadFeedback.fromJson(Map<String, dynamic> json) {
    return ThreadFeedback(
      message: json['message'],
      feedbackType: json['feedbackType'],
      rating: json['rating'],
      feedbackAt: json['feedbackAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (message != null) {
      data['message'] = message;
    }
    if (feedbackType != null) {
      data['feedbackType'] = feedbackType;
    }
    if (rating != null) {
      data['rating'] = rating;
    }
    if (feedbackAt != null) {
      data['feedbackAt'] = feedbackAt;
    }
    return data;
  }
}

class ThreadUserId {
  String? sId;
  String? name;
  String? email;
  String? phone;

  ThreadUserId({this.sId, this.name, this.email, this.phone});

  factory ThreadUserId.fromJson(Map<String, dynamic> json) {
    return ThreadUserId(
      sId: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class ThreadDepartment {
  String? sId;
  String? departmentId;
  String? name;
  String? description;

  ThreadDepartment({this.sId, this.departmentId, this.name, this.description});

  factory ThreadDepartment.fromJson(Map<String, dynamic> json) {
    return ThreadDepartment(
      sId: json['_id'],
      departmentId: json['departmentId'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'departmentId': departmentId,
      'name': name,
      'description': description,
    };
  }
}

class ThreadAuthority {
  String? sId;
  String? authorityId;
  String? name;
  String? designation;

  ThreadAuthority({this.sId, this.authorityId, this.name, this.designation});

  factory ThreadAuthority.fromJson(Map<String, dynamic> json) {
    return ThreadAuthority(
      sId: json['_id'],
      authorityId: json['authorityId'],
      name: json['name'],
      designation: json['designation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'authorityId': authorityId,
      'name': name,
      'designation': designation,
    };
  }
}

class ThreadConstituency {
  String? sId;
  String? name;
  String? area;
  String? constituencyId;

  ThreadConstituency({this.sId, this.name, this.area, this.constituencyId});

  factory ThreadConstituency.fromJson(Map<String, dynamic> json) {
    return ThreadConstituency(
      sId: json['_id'],
      name: json['name'],
      area: json['area'],
      constituencyId: json['constituencyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'area': area,
      'constituencyId': constituencyId,
    };
  }
}

class Message {
  String? messageId;
  String? from;
  String? to;
  String? subject;
  String? snippet;
  String? date;
  String? body;
  String? normalizedBody;
  bool? isRead;
  String? readAt;
  List<Attachments>? attachments;
  bool? isDeleted;
  String? sId;

  Message({
    this.messageId,
    this.from,
    this.to,
    this.subject,
    this.snippet,
    this.date,
    this.body,
    this.normalizedBody,
    this.isRead,
    this.readAt,
    this.attachments,
    this.isDeleted,
    this.sId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      from: json['from'],
      to: json['to'],
      subject: json['subject'],
      snippet: json['snippet'],
      date: json['date'],
      body: json['body'],
      normalizedBody: json['normalizedBody'],
      isRead: json['isRead'],
      readAt: json['readAt'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((v) => Attachments.fromJson(v))
              .toList()
          : null,
      isDeleted: json['isDeleted'],
      sId: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageId'] = messageId;
    data['from'] = from;
    data['to'] = to;
    data['subject'] = subject;
    data['snippet'] = snippet;
    data['date'] = date;
    data['body'] = body;
    if (isRead != null) {
      data['isRead'] = isRead;
    }
    if (readAt != null) {
      data['readAt'] = readAt;
    }
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    if (isDeleted != null) {
      data['isDeleted'] = isDeleted;
    }
    if (sId != null) {
      data['_id'] = sId;
    }
    return data;
  }
}
