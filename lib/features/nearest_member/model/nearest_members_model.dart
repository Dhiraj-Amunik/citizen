class NearestMembersModel {
  int? responseCode;
  String? message;
  Data? data;

  NearestMembersModel({this.responseCode, this.message, this.data});

  NearestMembersModel.fromJson(Map<String, dynamic> json) {
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
  int? totalPartyMember;
  int? page;
  int? pageSize;
  List<PartyMember>? partyMember;

  Data({this.totalPartyMember, this.page, this.pageSize, this.partyMember});

  Data.fromJson(Map<String, dynamic> json) {
    totalPartyMember = json['totalPartyMember'];
    page = json['page'];
    pageSize = json['pageSize'];
    // radiusUsed is optional and not used in the model, but present in API response
    if (json['partyMember'] != null) {
      partyMember = <PartyMember>[];
      try {
        final partyMemberList = json['partyMember'] as List;
        for (var v in partyMemberList) {
          try {
            partyMember!.add(new PartyMember.fromJson(v as Map<String, dynamic>));
          } catch (e) {
            print("Error parsing individual party member: $e");
            print("Member data: $v");
            // Continue parsing other members even if one fails
          }
        }
        print("Successfully parsed ${partyMember!.length} party members");
      } catch (e) {
        print("Error parsing partyMember list: $e");
        print("partyMember value: ${json['partyMember']}");
        partyMember = [];
      }
    } else {
      print("partyMember is null in response");
      partyMember = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalPartyMember'] = this.totalPartyMember;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.partyMember != null) {
      data['partyMember'] = this.partyMember!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PartyMember {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? avatar;
  Location? location;
  double? distance;
  PartyMemberDetails? partyMemberDetails;

  PartyMember(
      {this.sId,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.avatar,
      this.location,
      this.distance,
      this.partyMemberDetails});

  PartyMember.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    avatar = json['avatar'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    distance = json['distance'];
    partyMemberDetails = json['partyMemberDetails'] != null
        ? new PartyMemberDetails.fromJson(json['partyMemberDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['distance'] = this.distance;
    if (this.partyMemberDetails != null) {
      data['partyMemberDetails'] = this.partyMemberDetails!.toJson();
    }
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['coordinates'] != null) {
      try {
        final coords = json['coordinates'] as List;
        coordinates = coords.map((e) => (e as num).toDouble()).toList();
      } catch (e) {
        print("Error parsing coordinates: $e");
        print("Coordinates value: ${json['coordinates']}");
        coordinates = null;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class PartyMemberDetails {
  String? sId;
  String? status;
  String? type;

  PartyMemberDetails({this.sId, this.status,this.type});

  PartyMemberDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['status'] = this.status;
    return data;
  }
}
