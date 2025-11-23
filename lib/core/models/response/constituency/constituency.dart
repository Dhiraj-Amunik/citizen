part of 'constituency_model.dart';

class Constituency {
  String? sId;
  String? name;
  String? parliamentaryConstituencyId;
  String? assemblyConstituencyId;

  Constituency({this.sId, this.name, this.parliamentaryConstituencyId});

  Constituency.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    parliamentaryConstituencyId = json['parliamentaryConstituencyId'];
    assemblyConstituencyId = json['assemblyConstituencyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['parliamentaryConstituencyId'] = this.parliamentaryConstituencyId;
    data['assemblyConstituencyId'] = this.assemblyConstituencyId;

    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Constituency) return false;
    return other.sId == sId;
  }

  @override
  int get hashCode => (sId ?? '').hashCode;
}
