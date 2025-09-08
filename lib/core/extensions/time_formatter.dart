import 'package:intl/intl.dart';

extension TimeFormatting on String {
  String to12HourTime() {
    try {
      final DateTime parsedDate = DateTime.parse(this);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return this;
    }
  }

  String to24HourTime() {
    try {
      final DateTime parsedDate = DateTime.parse(this);
      return DateFormat('HH:mm').format(parsedDate);
    } catch (e) {
      return this;
    }
  }
}
