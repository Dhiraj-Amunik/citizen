class NotifyListModel {
  int? responseCode;
  String? message;
  Data? data;

  NotifyListModel({this.responseCode, this.message, this.data});

  NotifyListModel.fromJson(Map<String, dynamic> json) {
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
  int? totalNotifyRepresentative;
  int? page;
  int? pageSize;
  List<NotifyRepresentative>? notifyRepresentative;

  Data(
      {this.totalNotifyRepresentative,
      this.page,
      this.pageSize,
      this.notifyRepresentative});

  Data.fromJson(Map<String, dynamic> json) {
    totalNotifyRepresentative = json['totalNotifyRepresentative'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['notifyRepresentative'] != null) {
      notifyRepresentative = <NotifyRepresentative>[];
      json['notifyRepresentative'].forEach((v) {
        notifyRepresentative!.add(new NotifyRepresentative.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalNotifyRepresentative'] = this.totalNotifyRepresentative;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.notifyRepresentative != null) {
      data['notifyRepresentative'] =
          this.notifyRepresentative!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotifyRepresentative {
  String? location;
  String? sId;
  String? title;
  String? eventType;
  String? description;
  String? dateAndTime;
  List<String>? documents;
  List<SpecialInvite>? specialInvites;
  bool? isActive;
  bool? isDeleted;
  String? status;
  List<ResponseItem>? responses;
  String? createdAt;
  String? updatedAt;
  int? iV;
  PartyMember? partyMember;
  String? street;
  String? pincode;
  String? district;
  String? mandal;
  String? village;

  NotifyRepresentative(
      {this.location,
      this.sId,
      this.title,
      this.eventType,
      this.description,
      this.dateAndTime,
      this.documents,
      this.specialInvites,
      this.isActive,
      this.isDeleted,
      this.status,
      this.responses,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.partyMember,
      this.street,
      this.pincode,
      this.district,
      this.mandal,
      this.village});

  NotifyRepresentative.fromJson(Map<String, dynamic> json) {
    // Handle location - it might be a string or an object {lat, lng}
    if (json['location'] != null) {
      if (json['location'] is String) {
        location = json['location'];
      } else if (json['location'] is Map) {
        // If location is an object, we can't store it as string
        // Set to null and let UI construct from address fields
        location = null;
      } else {
        location = json['location'].toString();
      }
    } else {
      location = null;
    }
    sId = json['_id'];
    title = json['title'];
    eventType = json['eventType'];
    description = json['description'];
    dateAndTime = json['dateAndTime'];
    documents = json['documents'] != null
        ? List<String>.from(json['documents'])
        : <String>[];
    if (json['specialInvites'] != null) {
      specialInvites = <SpecialInvite>[];
      json['specialInvites'].forEach((v) {
        specialInvites!.add(SpecialInvite.fromJson(v));
      });
    } else {
      specialInvites = <SpecialInvite>[];
    }
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    status = json['status'];
    if (json['responses'] != null) {
      responses = <ResponseItem>[];
      json['responses'].forEach((v) {
        responses!.add(ResponseItem.fromJson(v));
      });
    } else {
      responses = <ResponseItem>[];
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    partyMember = json['partyMember'] != null
        ? new PartyMember.fromJson(json['partyMember'])
        : null;
    street = json['street'];
    pincode = json['pincode'];
    district = json['district'];
    mandal = json['mandal'];
    village = json['village'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['location'] = this.location;
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['eventType'] = this.eventType;
    data['description'] = this.description;
    data['dateAndTime'] = this.dateAndTime;
    data['documents'] = this.documents;
    if (specialInvites != null) {
      data['specialInvites'] =
          specialInvites!.map((SpecialInvite v) => v.toJson()).toList();
    }
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['status'] = this.status;
    if (responses != null) {
      data['responses'] =
          responses!.map((ResponseItem v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.partyMember != null) {
      data['partyMember'] = this.partyMember!.toJson();
    }
    data['street'] = this.street;
    data['pincode'] = this.pincode;
    data['district'] = this.district;
    data['mandal'] = this.mandal;
    data['village'] = this.village;
    return data;
  }
}

class PartyMember {
  String? sId;
  User? user;

  PartyMember({this.sId, this.user});

  PartyMember.fromJson(Map<String, dynamic> json) {
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

class SpecialInvite {
  SpecialInvite({this.name, this.email, this.phone});

  factory SpecialInvite.fromJson(Map<String, dynamic> json) {
    return SpecialInvite(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  final String? name;
  final String? email;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class ResponseItem {
  ResponseItem({
    this.mla,
    this.status,
    this.wishes,
    this.respondedAt,
    this.id,
  });

  factory ResponseItem.fromJson(Map<String, dynamic> json) {
    return ResponseItem(
      mla: json['mla'] != null ? Mla.fromJson(json['mla']) : null,
      status: json['status'],
      wishes:
          json['wishes'] != null ? Wishes.fromJson(json['wishes']) : null,
      respondedAt: json['respondedAt'],
      id: json['_id'],
    );
  }

  final Mla? mla;
  final String? status;
  final Wishes? wishes;
  final String? respondedAt;
  final String? id;

  Map<String, dynamic> toJson() {
    return {
      if (mla != null) 'mla': mla!.toJson(),
      'status': status,
      if (wishes != null) 'wishes': wishes!.toJson(),
      'respondedAt': respondedAt,
      '_id': id,
    };
  }
}

class Mla {
  Mla({this.id, this.user});

  factory Mla.fromJson(Map<String, dynamic> json) {
    return Mla(
      id: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  final String? id;
  final User? user;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class Wishes {
  Wishes({
    this.text,
    this.photos,
    this.voiceNotes,
  });

  factory Wishes.fromJson(Map<String, dynamic> json) {
    return Wishes(
      text: json['text'],
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : <String>[],
      voiceNotes: json['voiceNotes'] != null
          ? List<String>.from(json['voiceNotes'])
          : <String>[],  
    );
  }

  final String? text;
  final List<String>? photos;
  final List<String>? voiceNotes;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'photos': photos,
      'voiceNotes': voiceNotes,
    };
  }
}
