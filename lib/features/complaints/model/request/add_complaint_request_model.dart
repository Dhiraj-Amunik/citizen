class AddComplaintRequestModel {
  String? department;
  String? endUserEmail;
  String? name;
  String? title;
  String? description;

  AddComplaintRequestModel({
    this.department,
    this.endUserEmail,
    this.name,
    this.title,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['departmentname'] = this.department;
    data['enduserEmail'] = this.endUserEmail;
    data['name'] = this.name;
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}
