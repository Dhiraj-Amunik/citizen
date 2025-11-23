class NotifyFiltersModel {
  int? responseCode;
  String? message;
  NotifyFiltersData? data;

  NotifyFiltersModel({this.responseCode, this.message, this.data});

  NotifyFiltersModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null
        ? NotifyFiltersData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class NotifyFiltersData {
  List<ConstituencyFilter>? constituencies;
  List<MlaFilter>? mlas;
  List<String>? districts;
  List<String>? mandals;
  List<String>? villages;

  NotifyFiltersData({
    this.constituencies,
    this.mlas,
    this.districts,
    this.mandals,
    this.villages,
  });

  NotifyFiltersData.fromJson(Map<String, dynamic> json) {
    if (json['constituencies'] != null) {
      constituencies = <ConstituencyFilter>[];
      json['constituencies'].forEach((v) {
        constituencies!.add(ConstituencyFilter.fromJson(v));
      });
    }
    if (json['mlas'] != null) {
      mlas = <MlaFilter>[];
      json['mlas'].forEach((v) {
        mlas!.add(MlaFilter.fromJson(v));
      });
    }
    if (json['districts'] != null) {
      districts = <String>[];
      json['districts'].forEach((v) {
        districts!.add(v);
      });
    }
    if (json['mandals'] != null) {
      mandals = <String>[];
      json['mandals'].forEach((v) {
        mandals!.add(v);
      });
    }
    if (json['villages'] != null) {
      villages = <String>[];
      json['villages'].forEach((v) {
        villages!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.constituencies != null) {
      data['constituencies'] = this.constituencies!.map((v) => v.toJson()).toList();
    }
    if (this.mlas != null) {
      data['mlas'] = this.mlas!.map((v) => v.toJson()).toList();
    }
    if (this.districts != null) {
      data['districts'] = this.districts;
    }
    if (this.mandals != null) {
      data['mandals'] = this.mandals;
    }
    if (this.villages != null) {
      data['villages'] = this.villages;
    }
    return data;
  }
}

class ConstituencyFilter {
  String? sId;
  String? name;

  ConstituencyFilter({this.sId, this.name});

  ConstituencyFilter.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}

class MlaFilter {
  String? sId;
  MlaUser? user;
  String? constituency;

  MlaFilter({this.sId, this.user, this.constituency});

  MlaFilter.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? MlaUser.fromJson(json['user']) : null;
    constituency = json['constituency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['constituency'] = this.constituency;
    return data;
  }
}

class MlaUser {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? avatar;

  MlaUser({this.sId, this.name, this.email, this.phone, this.avatar});

  MlaUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['avatar'] = this.avatar;
    return data;
  }
}

