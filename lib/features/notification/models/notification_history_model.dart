class NotificationHistoryModel {
  int? responseCode;
  String? message;
  NotificationHistoryData? data;

  NotificationHistoryModel({this.responseCode, this.message, this.data});

  NotificationHistoryModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null
        ? NotificationHistoryData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class NotificationHistoryData {
  List<NotificationItem>? notifications;
  Pagination? pagination;
  int? unreadCount;

  NotificationHistoryData({
    this.notifications,
    this.pagination,
    this.unreadCount,
  });

  NotificationHistoryData.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <NotificationItem>[];
      json['notifications'].forEach((v) {
        notifications!.add(NotificationItem.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    unreadCount = json['unreadCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notifications != null) {
      data['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    data['unreadCount'] = unreadCount;
    return data;
  }
}

class NotificationItem {
  String? id;
  String? title;
  String? message;
  String? image;
  String? type;
  String? module;
  String? createdAt;
  bool? read;

  NotificationItem({
    this.id,
    this.title,
    this.message,
    this.image,
    this.type,
    this.module,
    this.createdAt,
    this.read,
  });

  NotificationItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['_id']; // Handle both id and _id just in case
    title = json['title'];
    message = json['message'];
    image = json['image'];
    type = json['type'];
    module = json['module'];
    createdAt = json['createdAt'];
    read = json['read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['message'] = message;
    data['image'] = image;
    data['type'] = type;
    data['module'] = module;
    data['createdAt'] = createdAt;
    data['read'] = read;
    return data;
  }
}

class Pagination {
  int? page;
  int? pageSize;
  int? total;
  int? totalPages;

  Pagination({this.page, this.pageSize, this.total, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['pageSize'] = pageSize;
    data['total'] = total;
    data['totalPages'] = totalPages;
    return data;
  }
}
