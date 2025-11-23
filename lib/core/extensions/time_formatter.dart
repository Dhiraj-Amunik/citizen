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

  /// Converts 24-hour time string (HH:mm) to 12-hour format with AM/PM
  /// Example: "13:00" -> "01:00 PM", "09:30" -> "09:30 AM"
  String to12HourTimeFormat() {
    try {
      // Handle time string in format "HH:mm" (e.g., "13:00", "09:30")
      if (this.contains(':')) {
        final parts = this.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            final period = hour >= 12 ? 'PM' : 'AM';
            final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
            final minuteStr = minute.toString().padLeft(2, '0');
            return '$displayHour:$minuteStr $period';
          }
        }
      }
      return this;
    } catch (e) {
      return this;
    }
  }
}
