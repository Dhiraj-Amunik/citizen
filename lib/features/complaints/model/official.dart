class Official {
  final String id;
  final String name;
  final String email;
  final String department;
  final String designation;
  final String phone;

  Official({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.phone,
  });

  factory Official.fromJson(Map<String, dynamic> json) {
    return Official(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      department: json['department'],
      designation: json['designation'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'designation': designation,
      'phone': phone,
    };
  }
}
