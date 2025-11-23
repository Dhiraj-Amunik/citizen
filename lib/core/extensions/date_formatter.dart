import 'package:intl/intl.dart';

extension DateFormatting on String {
  String toDdMmYyyy() {
    final DateTime parsedDate = DateTime.parse(this);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  String toDdMmmYyyy() {
    final DateTime parsedDate = DateTime.parse(this);
    return DateFormat('dd MMM, yyyy').format(parsedDate);
  }

  String toDdMmmYyyyWithTime() {
    try {
      final DateTime parsedDate = DateTime.parse(this);
      return DateFormat('dd MMM, yyyy hh:mm a').format(parsedDate);
    } catch (e) {
      // If parsing fails, return just the date
      return toDdMmmYyyy();
    }
  }

  String toYyyyMmDd() {
    final DateTime parsedDate = DateTime.parse(this);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }
}
