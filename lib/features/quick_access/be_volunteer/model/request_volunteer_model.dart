class RequestVolunteerModel {
  String name;
  String email;
  String phone;
  String age;
  String gender;
  String occupation;
  String address;
  List<String> areasOfInterest;
  String availability;
  String preferredTimeSlot;
  String hoursPerWeek;
  String mlaId;

  RequestVolunteerModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.address,
    required this.areasOfInterest,
    required this.availability,
    required this.preferredTimeSlot,
    required this.hoursPerWeek,
    required this.mlaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'address': address,
      'areasOfInterest': areasOfInterest,
      'availability': availability,
      'preferredTimeSlot': preferredTimeSlot,
      'hoursPerWeek': hoursPerWeek,
      'mlaId': mlaId,
    };
  }
}