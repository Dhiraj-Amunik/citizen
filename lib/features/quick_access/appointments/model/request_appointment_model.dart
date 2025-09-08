import 'package:inldsevak/core/extensions/capitalise_string.dart';

class RequestAppointmentModel {
  String name;
  String phone;
  String date;
  String timeSlot;
  String purpose;
  String reason;
  List<String> documents;
  String mlaId;
  Priority priority;

  RequestAppointmentModel({
    required this.name,
    required this.phone,
    required this.date,
    required this.timeSlot,
    required this.purpose,
    required this.reason,
    required this.documents,
    required this.mlaId,
    required this.priority,
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
    };
  }
}

enum Priority { high, medium, low }
