class AuthoritiesModel {
  int? responseCode;
  String? message;
  List<Data>? data;

  AuthoritiesModel({this.responseCode, this.message, this.data});

  AuthoritiesModel.fromJson(Map<String, dynamic> json) {
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
  String? sId;
  String? authorityId;
  String? name;
  String? designation;
  String? description;
  List<String>? email;
  String? phone;
  String? department; // Can be String (old) or will be extracted from object (new)
  String? constituency; // Can be String (old) or will be extracted from object (new)
  String? address;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<Authority>? authority;
  Level1Details? level1Details; // New field for level 1 authorities API
  Department? departmentObj; // New field for nested department object
  Constituency? constituencyObj; // New field for nested constituency object

  Data({
    this.sId,
    this.authorityId,
    this.name,
    this.designation,
    this.description,
    this.email,
    this.phone,
    this.department,
    this.constituency,
    this.address,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.authority,
    this.level1Details,
    this.departmentObj,
    this.constituencyObj,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    authorityId = json['authorityId'];
    name = json['name'];
    designation = json['designation'];
    description = json['description'];
    email = json['email'] != null ? json['email'].cast<String>() : [];
    phone = json['phone'];
    address = json['address'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    
    // Handle department - can be String (old format) or Object (new format)
    if (json['department'] != null) {
      if (json['department'] is String) {
        department = json['department'];
      } else if (json['department'] is Map) {
        departmentObj = Department.fromJson(json['department']);
        department = departmentObj?.sId;
      }
    }
    
    // Handle constituency - can be String (old format) or Object (new format)
    if (json['constituency'] != null) {
      if (json['constituency'] is String) {
        constituency = json['constituency'];
      } else if (json['constituency'] is Map) {
        constituencyObj = Constituency.fromJson(json['constituency']);
        constituency = constituencyObj?.sId;
      }
    }
    
    // Handle authority array (old format)
    if (json['authority'] != null) {
      authority = <Authority>[];
      json['authority'].forEach((v) {
        authority!.add(new Authority.fromJson(v));
      });
    }
    
    // Handle level1Details (new format)
    if (json['level1Details'] != null) {
      level1Details = Level1Details.fromJson(json['level1Details']);
      // Convert level1Details to Authority format for backward compatibility
      if (authority == null) {
        authority = <Authority>[];
      }
      authority!.add(Authority(
        level: level1Details?.level,
        email: level1Details?.email,
        index: level1Details?.index,
        name: level1Details?.name ?? name, // Use level1Details name or fallback to root name
        sId: this.sId, // Use main authority _id (not level1Details._id) - this is what API expects
      ));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['authorityId'] = this.authorityId;
    data['name'] = this.name;
    data['designation'] = this.designation;
    data['description'] = this.description;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['department'] = this.departmentObj?.toJson() ?? this.department;
    data['constituency'] = this.constituencyObj?.toJson() ?? this.constituency;
    data['address'] = this.address;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.authority != null) {
      data['authority'] = this.authority!.map((v) => v.toJson()).toList();
    }
    if (this.level1Details != null) {
      data['level1Details'] = this.level1Details!.toJson();
    }
    return data;
  }
}

class Level1Details {
  String? level;
  String? email;
  int? index;
  String? name;
  String? sId;

  Level1Details({this.level, this.email, this.index, this.name, this.sId});

  Level1Details.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    email = json['email'];
    index = json['index'];
    name = json['name'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['level'] = this.level;
    data['email'] = this.email;
    data['index'] = this.index;
    data['name'] = this.name;
    data['_id'] = this.sId;
    return data;
  }
}

class Department {
  String? sId;
  String? departmentId;
  String? name;

  Department({this.sId, this.departmentId, this.name});

  Department.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    departmentId = json['departmentId'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['departmentId'] = this.departmentId;
    data['name'] = this.name;
    return data;
  }
}

class Constituency {
  String? sId;
  String? name;
  String? constituencyId;

  Constituency({this.sId, this.name, this.constituencyId});

  Constituency.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    constituencyId = json['constituencyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['constituencyId'] = this.constituencyId;
    return data;
  }
}

class Authority {
  String? level;
  String? email;
  int? index;
  String? name;
  String? sId;

  Authority({this.level, this.email, this.index, this.name, this.sId});

  Authority.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    email = json['email'];
    index = json['index'];
    name = json['name'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['level'] = this.level;
    data['email'] = this.email;
    data['index'] = this.index;
    data['name'] = this.name;
    data['_id'] = this.sId;
    return data;
  }
}
