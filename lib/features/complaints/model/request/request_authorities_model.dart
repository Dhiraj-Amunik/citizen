class RequestAuthoritiesModel {
  final String? departemnetID;

  const RequestAuthoritiesModel({this.departemnetID});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['departmentId'] = this.departemnetID;
    return data;
  }
}
