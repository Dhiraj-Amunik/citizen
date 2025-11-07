class LokVartaModel {
  int? responseCode;
  String? message;
  Data? data;

  LokVartaModel({this.responseCode, this.message, this.data});

  LokVartaModel.fromJson(Map<String, dynamic> json) {
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
  int? totalMedia;
  int? page;
  int? pageSize;
  List<Media>? media;

  Data({this.totalMedia, this.page, this.pageSize, this.media});

  Data.fromJson(Map<String, dynamic> json) {
    totalMedia = json['totalMedia'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(new Media.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalMedia'] = this.totalMedia;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Media {
  String? sId;
  String? title;
  Mla? mla;
  String? mediaType;
  String? publishDate;
  String? status;
  String? content;
  List<String>? images;
  String? videoUrl;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? url;
  int? iV;

  Media({
    this.sId,
    this.title,
    this.mla,
    this.mediaType,
    this.publishDate,
    this.status,
    this.content,
    this.images,
    this.videoUrl,
    this.url,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Media.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    sId = json['_id'];
    title = json['title'];
    mla = json['mla'] != null ? new Mla.fromJson(json['mla']) : null;
    mediaType = json['mediaType'];
    publishDate = json['publishDate'];
    status = json['status'];
    content = json['content'];
    images = json['images'].cast<String>();
    videoUrl = json['videoUrl'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['_id'] = this.sId;
    data['title'] = this.title;
    if (this.mla != null) {
      data['mla'] = this.mla!.toJson();
    }
    data['mediaType'] = this.mediaType;
    data['publishDate'] = this.publishDate;
    data['status'] = this.status;
    data['content'] = this.content;
    data['images'] = this.images;
    data['videoUrl'] = this.videoUrl;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Mla {
  String? sId;
  User? user;
  User? constituency;

  Mla({this.sId, this.user, this.constituency});

  Mla.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    constituency = json['constituency'] != null
        ? new User.fromJson(json['constituency'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.constituency != null) {
      data['constituency'] = this.constituency!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? name;

  User({this.sId, this.name});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}
