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

  /// Converts 12-hour time string with AM/PM back to 24-hour format (HH:mm)
  /// Example: "01:00 PM" -> "13:00", "09:30 AM" -> "09:30", "12:00 AM" -> "00:00"
  String from12HourTo24HourFormat() {
    try {
      // Remove extra spaces and convert to uppercase for consistent parsing
      final trimmed = this.trim().toUpperCase();
      
      // Check if it contains AM/PM
      if (!trimmed.contains('AM') && !trimmed.contains('PM')) {
        // Already in 24-hour format or invalid format, return as is
        return this;
      }
      
      // Extract AM/PM
      final isPM = trimmed.contains('PM');
      final isAM = trimmed.contains('AM');
      
      // Remove AM/PM from the string
      String timeStr = trimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
      
      // Parse hour and minute
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0].trim());
          final minute = int.tryParse(parts[1].trim());
          
          if (hour != null && minute != null && hour >= 1 && hour <= 12 && minute >= 0 && minute < 60) {
            int hour24 = hour;
            
            // Convert to 24-hour format
            if (isAM) {
              // AM: 12:00 AM -> 00:00, 1:00 AM -> 01:00, 11:00 AM -> 11:00
              hour24 = hour == 12 ? 0 : hour;
            } else if (isPM) {
              // PM: 12:00 PM -> 12:00, 1:00 PM -> 13:00, 11:00 PM -> 23:00
              hour24 = hour == 12 ? 12 : hour + 12;
            }
            
            // Format as HH:mm
            final hourStr = hour24.toString().padLeft(2, '0');
            final minuteStr = minute.toString().padLeft(2, '0');
            return '$hourStr:$minuteStr';
          }
        }
      }
      
      return this;
    } catch (e) {
      return this;
    }
  }
}
