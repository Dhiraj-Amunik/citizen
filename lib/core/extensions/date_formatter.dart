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

  String toYyyyMmDd() {
    final DateTime parsedDate = DateTime.parse(this);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }
}
