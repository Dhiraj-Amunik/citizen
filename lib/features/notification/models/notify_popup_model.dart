class NotifyPopupModel {
  int? responseCode;
  String? message;
  List<NotifyPopupItem>? data;

  NotifyPopupModel({this.responseCode, this.message, this.data});

  NotifyPopupModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NotifyPopupItem>[];
      json['data'].forEach((v) {
        data!.add(NotifyPopupItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotifyPopupItem {
  String? id;
  String? title;
  String? message;
  String? image;
  String? type;
  String? module;
  String? createdAt;
  bool? read;

  NotifyPopupItem({
    this.id,
    this.title,
    this.message,
    this.image,
    this.type,
    this.module,
    this.createdAt,
    this.read,
  });

  NotifyPopupItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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
