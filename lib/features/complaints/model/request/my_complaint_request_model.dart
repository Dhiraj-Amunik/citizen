class MyComplaintRequestModel {
  final String? departmentId;
  final List<String>? status;
  final String? date;
  final String? startDate;
  final String? endDate;

  MyComplaintRequestModel({
    this.departmentId,
    this.status,
    this.date,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'departmentId': departmentId ?? "",
      'status': status?.map((s) => s.toLowerCase()).toList() ?? [],
      'date': date ?? "",
      'startDate': startDate ?? "",
      'endDate': endDate ?? "",
    };
  }
}
