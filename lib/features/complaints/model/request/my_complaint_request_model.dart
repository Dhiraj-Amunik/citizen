class MyComplaintRequestModel {
  final String? departmentId;
  final List<String>? status;
  final String? date;
  final String? startDate;
  final String? endDate;
  final int? limit;

  MyComplaintRequestModel({
    this.departmentId,
    this.status,
    this.date,
    this.startDate,
    this.endDate,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'departmentId': departmentId ?? "",
      'status': status?.map((s) => s.toLowerCase()).toList() ?? [],
      'date': date ?? "",
      'startDate': startDate ?? "",
      'endDate': endDate ?? "",
      'limit': limit ?? 100,
    };
  }
}
