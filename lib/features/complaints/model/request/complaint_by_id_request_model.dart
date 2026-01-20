class ComplaintByIdRequestModel {
  String? complaintId;

  ComplaintByIdRequestModel({this.complaintId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (complaintId != null) {
      data['complaintId'] = complaintId;
    }
    return data;
  }
}































