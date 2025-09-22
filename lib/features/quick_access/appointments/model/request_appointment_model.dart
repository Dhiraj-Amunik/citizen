import 'package:inldsevak/core/extensions/capitalise_string.dart';

class RequestAppointmentModel {
  String name;
  String phone;
  String date;
  String? timeSlot;
  String purpose;
  String reason;
  List<String> documents;
  String mlaId;
  Priority priority;
  String? bookFor;
  String? memberShipID;

  RequestAppointmentModel({
    required this.name,
    required this.phone,
    required this.date,
    this.timeSlot = "00:00",
    required this.purpose,
    required this.reason,
    required this.documents,
    required this.mlaId,
    required this.priority,
    required this.bookFor,
    required this.memberShipID,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'date': date,
      'timeSlot': timeSlot,
      'purpose': purpose,
      'reason': reason,
      'documents': documents,
      'mlaId': mlaId,
      'priority': priority.name.capitalize(),
      'bookFor': bookFor,
      'memberShipId': memberShipID,
    };
  }
}

enum Priority { high, medium, low }
